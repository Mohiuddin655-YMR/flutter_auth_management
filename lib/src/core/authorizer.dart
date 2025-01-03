import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_entity/flutter_entity.dart';

import '../models/auth.dart';
import '../models/auth_providers.dart';
import '../models/auth_status.dart';
import '../models/auth_type.dart';
import '../models/biometric_config.dart';
import '../models/biometric_status.dart';
import '../utils/auth_notifier.dart';
import '../utils/auth_response.dart';
import '../utils/authenticator.dart';
import 'messages.dart';
import 'repository_auth.dart';
import 'repository_backup.dart';
import 'typedefs.dart';

class Authorizer<T extends Auth> {
  final AuthMessages msg;
  final AuthRepository authRepository;
  final BackupRepository<T> backupRepository;
  final _errorNotifier = AuthNotifier("");
  final _loadingNotifier = AuthNotifier(false);
  final _messageNotifier = AuthNotifier("");
  final _userNotifier = AuthNotifier<T?>(null);
  final _statusNotifier = AuthNotifier(AuthStatus.unauthenticated);

  Object? _args;

  String? _id;

  Object? get args => _args;

  String? get id => _id;

  Future<T?> get _auth => backupRepository.cache;

  Authorizer({
    required this.authRepository,
    required this.backupRepository,
    this.msg = const AuthMessages(),
  });

  Future<T?> get auth async {
    try {
      final value = await _auth;
      if (value == null || !value.isLoggedIn) return null;
      return value;
    } catch (error) {
      return null;
    }
  }

  String get errorText => _errorNotifier.value;

  Future<bool> get isBiometricEnabled async {
    try {
      final value = await _auth;
      return value != null && value.isBiometric;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return false;
    }
  }

  Future<bool> get isLoggedIn async {
    final value = await auth;
    return value != null && value.isLoggedIn;
  }

  AuthNotifier<String> get liveError => _errorNotifier;

  AuthNotifier<bool> get liveLoading => _loadingNotifier;

  AuthNotifier<String> get liveMessage => _messageNotifier;

  AuthNotifier<AuthStatus> get liveStatus => _statusNotifier;

  AuthNotifier<T?> get liveUser => _userNotifier;

  bool get loading => _loadingNotifier.value;

  String get message => _messageNotifier.value;

  AuthStatus get status => _statusNotifier.value;

  T? get user => _userNotifier.value;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Stream<User?> get firebaseAuthChanges {
    return FirebaseAuth.instance.authStateChanges();
  }

  Stream<User?> get firebaseIdTokenChanges {
    return FirebaseAuth.instance.idTokenChanges();
  }

  Stream<User?> get firebaseUserChanges {
    return FirebaseAuth.instance.userChanges();
  }

  Future<Response<T>> addBiometric({
    SignByBiometricCallback? callback,
    BiometricConfig? config,
  }) async {
    try {
      final auth = await _auth;
      final provider = AuthProviders.from(auth?.provider);
      if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
        return Response(
          status: Status.notSupported,
          error: "User not logged in with email or username!",
        );
      }

      final response = await authRepository.signInWithBiometric(config: config);
      if (!response.isSuccessful) {
        return Response(status: response.status, error: response.error);
      }

      final biometric = callback != null
          ? await callback(auth.biometric)
          : BiometricStatus.activated;
      final value = await _update(
        id: auth.id,
        updateMode: true,
        updates: {
          AuthKeys.i.biometric: biometric?.name,
        },
      );

      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(
        status: Status.failure,
        error: error.toString(),
      );
    }
  }

  Future<Response<T>> biometricEnable(bool enabled) async {
    final auth = await _auth;
    final provider = AuthProviders.from(auth?.provider);
    final permission = auth != null &&
        auth.isLoggedIn &&
        !auth.biometric.isInitial &&
        provider.isAllowBiometric;

    if (!permission) {
      return Response(
        status: Status.undefined,
        error: "Biometric not initialized yet!",
      );
    }

    try {
      final activated = BiometricStatus.value(enabled);
      final value = await _update(
        id: auth.id,
        updateMode: true,
        updates: {
          AuthKeys.i.biometric: activated.name,
        },
      );

      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(
        status: Status.failure,
        error: error.toString(),
      );
    }
  }

  Future<AuthResponse<T>> delete({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthProviders.none, AuthType.delete),
      args: args,
      id: id,
      notifiable: notifiable,
    );
    final data = await auth;
    if (data == null) {
      return emit(
        AuthResponse.rollback(
          data,
          msg: msg.loggedIn.failure,
          provider: AuthProviders.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    try {
      final response = await authRepository.delete;
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.rollback(
            data,
            msg: response.message,
            provider: AuthProviders.none,
            type: AuthType.delete,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      await _delete();
      await backupRepository.onDeleteUser(data.id);

      return emit(
        AuthResponse.unauthenticated(
          msg: msg.delete.done,
          provider: AuthProviders.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.rollback(
          data,
          msg: msg.delete.failure ?? error,
          provider: AuthProviders.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<bool> _delete() async {
    try {
      final cleared = await backupRepository.clear();
      if (cleared) _emitUser(null);
      return cleared;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return false;
    }
  }

  void dispose() {
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
    _messageNotifier.dispose();
    _statusNotifier.dispose();
    _userNotifier.dispose();
  }

  Future<AuthResponse<T>> emit(
    AuthResponse<T> data, {
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    _args = args;
    _id = id;
    if (notifiable) {
      if (data.isLoading) {
        _emitLoading(true);
      } else {
        _emitLoading(false);
        _emitError(data);
        _emitMessage(data);
        _emitStatus(data);
        _emitUser(data.data);
      }
    } else {
      if (!data.isLoading) _emitUser(data.data);
    }

    return data;
  }

  void _emitError(AuthResponse<T> data) {
    if (data.isError) {
      _errorNotifier.notifiable = data.error;
    }
  }

  void _emitLoading(bool data) {
    if (loading != data) {
      _loadingNotifier.value = data;
    }
  }

  void _emitMessage(AuthResponse<T> data) {
    if (data.isMessage) {
      _errorNotifier.notifiable = data.error;
    }
  }

  void _emitStatus(AuthResponse<T> data) {
    if (data.isState && _statusNotifier.value != data.state) {
      _statusNotifier.value = data.state;
    }
  }

  T? _emitUser(T? data) {
    if (data != null) _userNotifier.value = data;
    return _userNotifier.value;
  }

  Future<T?> initialize([bool initialCheck = true]) async {
    final value = await auth;
    if (value == null) return null;
    if (initialCheck) {
      if (value.isLoggedIn) {
        _statusNotifier.value = AuthStatus.authenticated;
      }
    }
    final remote = await backupRepository.onFetchUser(value.id);
    _userNotifier.value = remote;
    await backupRepository.setAsLocal(remote ?? value);
    return remote ?? value;
  }

  Future<AuthResponse<T>> isSignIn({
    AuthProviders? provider,
  }) async {
    try {
      final signedIn = await authRepository.isSignIn(provider);
      final data = signedIn ? await auth : null;
      if (data == null) {
        if (signedIn) await authRepository.signOut(provider);
        return AuthResponse.unauthenticated(
          provider: provider,
          type: AuthType.signedIn,
        );
      }

      return AuthResponse.authenticated(
        data,
        provider: provider,
        type: AuthType.signedIn,
      );
    } catch (error) {
      return AuthResponse.failure(
        msg.loggedIn.failure ?? error,
        provider: provider,
        type: AuthType.signedIn,
      );
    }
  }

  Future<AuthResponse<T>> signInAnonymously({
    GuestAuthenticator? authenticator,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      emit(
        const AuthResponse.loading(AuthProviders.email, AuthType.login),
        args: args,
        id: id,
        notifiable: notifiable,
      );

      final response = await authRepository.signInAnonymously();
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.guest,
            type: AuthType.none,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.guest,
            type: AuthType.none,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = (authenticator ?? Authenticator.guest()).copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );
      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithEmail.done,
          provider: AuthProviders.guest,
          type: AuthType.none,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          msg.signInWithEmail.failure ?? error,
          provider: AuthProviders.guest,
          type: AuthType.none,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(
        AuthProviders.biometric,
        AuthType.biometric,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final user = await _auth;
      if (user == null || !user.isBiometric) {
        return emit(
          AuthResponse.unauthorized(
            msg: msg.signInWithBiometric.failure ?? errorText,
            provider: AuthProviders.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final response = await authRepository.signInWithBiometric(config: config);
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final token = user.accessToken;
      final provider = AuthProviders.from(user.provider);
      var current = Response<UserCredential>();
      if ((user.email ?? user.username ?? "").isNotEmpty &&
          (user.password ?? '').isNotEmpty) {
        if (provider.isEmail) {
          current = await authRepository.signInWithEmailNPassword(
            email: user.email ?? "",
            password: user.password ?? "",
          );
        } else if (provider.isUsername) {
          current = await authRepository.signInWithUsernameNPassword(
            username: user.username ?? "",
            password: user.password ?? "",
          );
        }
      } else if ((token ?? user.idToken ?? "").isNotEmpty) {
        if (provider.isApple) {
          current = await authRepository.signInWithCredential(
            credential: OAuthProvider("apple.com").credential(
              idToken: user.idToken,
              accessToken: token,
            ),
          );
        } else if (provider.isFacebook) {
          current = await authRepository.signInWithCredential(
            credential: FacebookAuthProvider.credential(token ?? ""),
          );
        } else if (provider.isGoogle) {
          current = await authRepository.signInWithCredential(
            credential: GoogleAuthProvider.credential(
              idToken: user.idToken,
              accessToken: token,
            ),
          );
        }
      }
      if (!current.isSuccessful) {
        return emit(
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(id: user.id, updates: {
        AuthKeys.i.loggedIn: true,
        AuthKeys.i.loggedInTime: Entity.generateTimeMills,
      });

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithBiometric.done,
          provider: AuthProviders.biometric,
          type: AuthType.biometric,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          msg.signInWithBiometric.failure ?? error,
          provider: AuthProviders.biometric,
          type: AuthType.biometric,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthProviders.email, AuthType.login),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final response = await authRepository.signInWithEmailNPassword(
        email: authenticator.email,
        password: authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.email,
            type: AuthType.login,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.email,
            type: AuthType.login,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.email,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
        updates: {
          ...user.extra ?? {},
          if (biometric != null) AuthKeys.i.biometric: biometric.id,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithEmail.done,
          provider: AuthProviders.email,
          type: AuthType.login,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          msg.signInWithEmail.failure ?? error,
          provider: AuthProviders.email,
          type: AuthType.login,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(PhoneAuthCredential credential)? onComplete,
    void Function(FirebaseAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      authRepository.verifyPhoneNumber(
        phoneNumber: authenticator.phone,
        forceResendingToken: int.tryParse(authenticator.accessToken ?? ""),
        multiFactorInfo: multiFactorInfo,
        multiFactorSession: multiFactorSession,
        timeout: timeout,
        onComplete: (PhoneAuthCredential credential) async {
          if (onComplete != null) {
            emit(
              const AuthResponse.message(
                "Verification done!",
                provider: AuthProviders.phone,
                type: AuthType.otp,
              ),
              args: args,
              id: id,
              notifiable: notifiable,
            );
            onComplete(credential);
          } else {
            final verId = credential.verificationId;
            final code = credential.smsCode;
            if (verId != null && code != null) {
              signInByOtp(
                authenticator.otp(
                  token: verId,
                  smsCode: code,
                ),
              );
            } else {
              emit(
                const AuthResponse.failure(
                  "Verification token or otp code not valid!",
                  provider: AuthProviders.phone,
                  type: AuthType.otp,
                ),
                args: args,
                id: id,
                notifiable: notifiable,
              );
            }
          }
        },
        onCodeSent: (String verId, int? forceResendingToken) {
          emit(
            const AuthResponse.message(
              "Code sent to your device!",
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onCodeSent != null) onCodeSent(verId, forceResendingToken);
        },
        onFailed: (FirebaseAuthException exception) {
          emit(
            AuthResponse.failure(
              exception.message,
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onFailed != null) onFailed(exception);
        },
        onCodeAutoRetrievalTimeout: (String verId) {
          emit(
            const AuthResponse.failure(
              "Auto retrieval code timeout!",
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout(verId);
          }
        },
      );
      return emit(
        const AuthResponse.loading(
          AuthProviders.phone,
          AuthType.otp,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          msg.signOut.failure ?? error,
          provider: AuthProviders.phone,
          type: AuthType.otp,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthProviders.phone, AuthType.phone),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final credential = authenticator.credential;
      final response = await authRepository.signInWithCredential(
        credential: credential,
      );

      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.phone,
            type: AuthType.phone,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.phone,
            type: AuthType.phone,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        accessToken: storeToken ? credential.accessToken : null,
        idToken: storeToken && credential.token != null
            ? "${credential.token}"
            : null,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.phone,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithPhone.done,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          msg.signInWithPhone.failure ?? error,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.username, AuthType.login),
    );

    try {
      final response = await authRepository.signInWithUsernameNPassword(
        username: authenticator.username,
        password: authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.username,
            type: AuthType.login,
          ),
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.username,
            type: AuthType.login,
          ),
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.username,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
        updates: {
          ...user.extra ?? {},
          if (biometric != null) AuthKeys.i.biometric: biometric.id,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithUsername.done,
          provider: AuthProviders.username,
          type: AuthType.login,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithUsername.failure ?? error,
          provider: AuthProviders.username,
          type: AuthType.login,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.email, AuthType.register),
    );
    try {
      final response = await authRepository.signUpWithEmailNPassword(
        email: authenticator.email,
        password: authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.email,
            type: AuthType.register,
          ),
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.email,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = Entity.generateTimeMills;
      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.email,
        loggedIn: true,
        loggedInTime: creationTime,
        timeMills: creationTime,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signUpWithEmail.done,
          provider: AuthProviders.email,
          type: AuthType.register,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signUpWithEmail.failure ?? error,
          provider: AuthProviders.email,
          type: AuthType.register,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.username, AuthType.register),
    );

    try {
      final response = await authRepository.signUpWithUsernameNPassword(
        username: authenticator.username,
        password: authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.username,
            type: AuthType.register,
          ),
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.username,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = Entity.generateTimeMills;
      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.username,
        loggedIn: true,
        loggedInTime: creationTime,
        timeMills: creationTime,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signUpWithUsername.done,
          provider: AuthProviders.username,
          type: AuthType.register,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signUpWithUsername.failure ?? error,
          provider: AuthProviders.username,
          type: AuthType.register,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signOut({
    AuthProviders? provider,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      provider ??= (await _auth)?.provider;
      emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.loading(provider, AuthType.logout),
      );
      final response = await authRepository.signOut(provider);
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: provider,
            type: AuthType.logout,
          ),
        );
      }

      final data = await _auth;
      if (data == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.unauthenticated(
            msg: msg.signOut.done,
            provider: provider,
            type: AuthType.logout,
          ),
        );
      }

      await update({
        AuthKeys.i.loggedIn: false,
        AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
      });

      if (data.isBiometric) {
        await _update(
          id: data.id,
          updates: {
            ...data.extra ?? {},
            AuthKeys.i.loggedIn: false,
            AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
          },
        );
      } else {
        await _delete();
      }

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.unauthenticated(
          msg: msg.signOut.done,
          provider: provider,
          type: AuthType.logout,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signOut.failure ?? error,
          provider: provider,
          type: AuthType.logout,
        ),
      );
    }
  }

  Future<T?> update(
    Map<String, dynamic> data, {
    String? id,
    bool notifiable = true,
  }) async {
    try {
      await backupRepository.update(data);
      final updated = await auth;
      if (notifiable) _emitUser(updated);
      return updated;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<T?> _update({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool updateMode = false,
  }) async {
    try {
      await backupRepository.save(
        id: id,
        initials: initials,
        cacheUpdateMode: updateMode,
        updates: updates,
      );
      final updated = await _auth;
      _emitUser(updated);
      return updated;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<AuthResponse> verifyPhoneByOtp(OtpAuthenticator authenticator) async {
    try {
      final credential = authenticator.credential;
      final response = await authRepository.signInWithCredential(
        credential: credential,
      );
      if (!response.isSuccessful) {
        return AuthResponse.failure(
          response.error,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        );
      }

      final result = response.data?.user;
      if (result == null) {
        return AuthResponse.failure(
          msg.authorization,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        accessToken: credential.accessToken,
        idToken: credential.token != null ? "${credential.token}" : null,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: AuthProviders.phone,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      return AuthResponse.authenticated(
        user,
        msg: msg.signInWithPhone.done,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      );
    } catch (error) {
      return AuthResponse.failure(
        msg.signInWithPhone.failure ?? error,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      );
    }
  }

  Future<AuthResponse<T>> signInWithApple({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.apple, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithApple();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.apple,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithApple.done,
          provider: AuthProviders.apple,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithApple.failure ?? error,
          provider: AuthProviders.apple,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithFacebook({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.facebook, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithFacebook();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.facebook,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithFacebook.done,
          provider: AuthProviders.facebook,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithFacebook.failure ?? error,
          provider: AuthProviders.facebook,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGameCenter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(
        AuthProviders.gameCenter,
        AuthType.oauth,
      ),
    );

    try {
      final response = await authRepository.signInWithGameCenter();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.gameCenter,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.gameCenter,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.gameCenter,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGithub({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.github, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithGithub();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.github,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.github,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.github,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.github,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.github,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.github,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGoogle({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.google, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithGoogle();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.google,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.google,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.google,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.google,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGoogle.done,
          provider: AuthProviders.google,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGoogle.failure ?? error,
          provider: AuthProviders.google,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithMicrosoft({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.microsoft, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithMicrosoft();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.microsoft,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.microsoft,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.microsoft,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithPlayGames({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.playGames, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithPlayGames();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.playGames,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.playGames,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.playGames,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithSAML({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.saml, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithSAML();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.saml,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.saml,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.saml,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithTwitter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.twitter, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithTwitter();
      final raw = response.data;

      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.twitter,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.twitter,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.twitter,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithYahoo({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(AuthProviders.yahoo, AuthType.oauth),
    );

    try {
      final response = await authRepository.signInWithYahoo();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: AuthProviders.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await authRepository.signInWithCredential(
        credential: raw.credential!,
      );
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: AuthProviders.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data?.user;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.name ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photo ?? result.photoURL,
        provider: AuthProviders.yahoo,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
          provider: AuthProviders.yahoo,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          msg.signInWithGithub.failure ?? error,
          provider: AuthProviders.yahoo,
          type: AuthType.oauth,
        ),
      );
    }
  }
}
