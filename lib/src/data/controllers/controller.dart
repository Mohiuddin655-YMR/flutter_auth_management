import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_entity/flutter_entity.dart';

import '../../core/messages.dart';
import '../../core/typedefs.dart';
import '../../core/validator.dart';
import '../../delegates/backup.dart';
import '../../delegates/oauth.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/auth_state.dart';
import '../../models/auth_type.dart';
import '../../models/biometric_config.dart';
import '../../models/biometric_status.dart';
import '../../services/controllers/controller.dart';
import '../../services/handlers/auth_handler.dart';
import '../../services/handlers/backup_handler.dart';
import '../../services/sources/auth_data_source.dart';
import '../../services/sources/authorized_data_source.dart';
import '../../utils/auth_notifier.dart';
import '../../utils/auth_response.dart';
import '../../utils/authenticator.dart';
import '../../utils/authenticator_email.dart';
import '../../utils/authenticator_guest.dart';
import '../../utils/authenticator_oauth.dart';
import '../../utils/authenticator_otp.dart';
import '../../utils/authenticator_phone.dart';
import '../../utils/authenticator_username.dart';
import '../handlers/auth_handler.dart';
import '../handlers/backup_handler.dart';
import '../sources/auth_data_source.dart';
import '../sources/authorized_data_source.dart';

class AuthControllerImpl<T extends Auth> extends AuthController<T> {
  final AuthMessages msg;
  final AuthHandler authHandler;
  final BackupHandler<T> backupHandler;
  final _errorNotifier = AuthNotifier("");
  final _loadingNotifier = AuthNotifier(false);
  final _messageNotifier = AuthNotifier("");
  final _userNotifier = AuthNotifier<T?>(null);
  final _stateNotifier = AuthNotifier(AuthState.unauthenticated);

  Future<T?> get _auth => backupHandler.cache;

  AuthControllerImpl({
    OAuthDelegates? auth,
    BackupDelegate<T>? backup,
    AuthMessages? messages,
  }) : this.fromSource(
          auth: AuthDataSourceImpl(auth),
          backup: AuthorizedDataSourceImpl(backup),
        );

  AuthControllerImpl.fromSource({
    required AuthDataSource auth,
    AuthorizedDataSource<T>? backup,
    AuthMessages? messages,
  }) : this.fromHandler(
          messages: messages,
          authHandler: AuthHandlerImpl(auth),
          backupHandler: backup != null ? BackupHandlerImpl<T>(backup) : null,
        );

  AuthControllerImpl.fromHandler({
    required this.authHandler,
    BackupHandler<T>? backupHandler,
    AuthMessages? messages,
  })  : msg = messages ?? const AuthMessages(),
        backupHandler =
            backupHandler ?? BackupHandlerImpl<T>(AuthorizedDataSourceImpl());

  @override
  Future<T?> get auth {
    return _auth.then((value) {
      return value != null && value.isLoggedIn ? value : null;
    });
  }

  @override
  String get error => _errorNotifier.value;

  @override
  Future<bool> get isBiometricEnabled {
    return _auth.then((value) => value != null && value.isBiometric);
  }

  @override
  Future<bool> get isLoggedIn {
    return auth.then((value) {
      final loggedIn = value != null && value.isLoggedIn;
      if (loggedIn) {
        _stateNotifier.value = AuthState.authenticated;
        _userNotifier.value = value;
        return true;
      } else {
        return false;
      }
    });
  }

  @override
  AuthNotifier<String> get liveError => _errorNotifier;

  @override
  AuthNotifier<bool> get liveLoading => _loadingNotifier;

  @override
  AuthNotifier<String> get liveMessage => _messageNotifier;

  @override
  AuthNotifier<AuthState> get liveState => _stateNotifier;

  @override
  AuthNotifier<T?> get liveUser => _userNotifier;

  @override
  bool get loading => _loadingNotifier.value;

  @override
  String get message => _messageNotifier.value;

  @override
  AuthState get state => _stateNotifier.value;

  @override
  T? get user => _userNotifier.value;

  @override
  Future<Response<bool>> addBiometric({
    SignByBiometricCallback? callback,
    BiometricConfig? config,
  }) async {
    final auth = await _auth;
    final provider = AuthProviders.from(auth?.provider);
    if (auth != null && auth.isLoggedIn && provider.isAllowBiometric) {
      try {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful && (response.data ?? false)) {
          final biometric = callback != null
              ? await callback(auth.mBiometric)
              : BiometricStatus.activated;
          return _update(
            id: auth.id,
            updateMode: true,
            updates: {
              AuthKeys.i.biometric: biometric?.name,
            },
          ).then((_) => Response(status: Status.ok, data: true));
        } else {
          return Response(
            status: response.status,
            exception: response.exception,
          );
        }
      } catch (error) {
        return Response(status: Status.failure, exception: error.toString());
      }
    } else {
      return Response(
        status: Status.notSupported,
        exception: "User not logged in with email or username!",
      );
    }
  }

  @override
  Future<Response<bool>> biometricEnable(bool enabled) async {
    final auth = await _auth;
    final provider = AuthProviders.from(auth?.provider);
    final permission = auth != null &&
        auth.isLoggedIn &&
        !auth.mBiometric.isInitial &&
        provider.isAllowBiometric;
    if (permission) {
      try {
        final activated = BiometricStatus.value(enabled);
        return _update(
          id: auth.id,
          updateMode: true,
          updates: {
            AuthKeys.i.biometric: activated.name,
          },
        ).then((_) {
          return Response(status: Status.ok, data: true);
        });
      } catch (error) {
        return Response(status: Status.failure, exception: error.toString());
      }
    } else {
      return Response(
        status: Status.undefined,
        exception: "Biometric not initialized yet!",
      );
    }
  }

  @override
  Future<AuthResponse<T>> delete() async {
    emit(const AuthResponse.loading(AuthProviders.none, AuthType.delete));
    var data = await auth;
    if (data != null) {
      try {
        return authHandler.delete.then((response) {
          if (response.isSuccessful) {
            return _delete().then((value) {
              return backupHandler.onDeleteUser(data.id).then((value) {
                return emit(AuthResponse.unauthenticated(
                  msg: msg.delete.done,
                  provider: AuthProviders.none,
                  type: AuthType.delete,
                ));
              });
            });
          } else {
            return emit(AuthResponse.rollback(
              data,
              msg: response.message,
              provider: AuthProviders.none,
              type: AuthType.delete,
            ));
          }
        });
      } catch (error) {
        return emit(AuthResponse.rollback(
          data,
          msg: msg.delete.failure ?? error,
          provider: AuthProviders.none,
          type: AuthType.delete,
        ));
      }
    } else {
      return emit(AuthResponse.rollback(
        data,
        msg: msg.loggedIn.failure,
        provider: AuthProviders.none,
        type: AuthType.delete,
      ));
    }
  }

  Future<bool> _delete() {
    return backupHandler.clear().then((clear) {
      if (clear) _emitUser(null);
      return clear;
    });
  }

  @override
  void dispose() {
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
    _messageNotifier.dispose();
    _stateNotifier.dispose();
    _userNotifier.dispose();
  }

  @override
  Future<AuthResponse<T>> emit(AuthResponse<T> data) async {
    if (data.isLoading) {
      _emitLoading(true);
    } else {
      _emitLoading(false);
      _emitError(data);
      _emitMessage(data);
      _emitState(data);
      _emitUser(data.data);
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

  void _emitState(AuthResponse<T> data) {
    if (data.isState && _stateNotifier.value != data.state) {
      _stateNotifier.value = data.state;
    }
  }

  T? _emitUser(T? data) {
    if (data != null) _userNotifier.value = data;
    return _userNotifier.value;
  }

  @override
  Future<T?> initialize([bool initialCheck = true]) {
    return auth.then((value) {
      if (value != null) {
        if (initialCheck) {
          if (value.isLoggedIn) {
            _stateNotifier.value = AuthState.authenticated;
          } else {
            _stateNotifier.value = AuthState.unauthenticated;
          }
        }
        return backupHandler.onFetchUser(value.id).then((remote) {
          _userNotifier.value = remote;
          return backupHandler.setAsLocal(remote ?? value).then((_) {
            return remote ?? value;
          });
        });
      } else {
        return value;
      }
    });
  }

  @override
  Future<AuthResponse<T>> isSignIn([
    AuthProviders? provider,
  ]) async {
    try {
      emit(AuthResponse.loading(provider));
      final signedIn = await authHandler.isSignIn(provider);
      final data = signedIn ? await auth : null;
      if (data != null) {
        return emit(AuthResponse.authenticated(
          data,
          provider: provider,
          type: AuthType.signedIn,
        ));
      } else {
        return emit(AuthResponse.unauthenticated(
          provider: provider,
          type: AuthType.signedIn,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.loggedIn.failure ?? error,
        provider: provider,
        type: AuthType.signedIn,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInAnonymously([
    GuestAuthenticator? authenticator,
  ]) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.email, AuthType.login));
      final response = await authHandler.signInAnonymously();
      if (response.isSuccessful) {
        final result = response.data?.user;
        if (result != null) {
          final user = (authenticator ?? Authenticator.guest()).copy(
            id: result.uid,
            email: result.email,
            name: result.displayName,
            phone: result.phoneNumber,
            photo: result.photoURL,
            loggedIn: true,
            loggedInTime: Entity.generateTimeMills,
          );
          return _update(
            id: user.id,
            initials: user.source,
            updates: {
              ...user.extra ?? {},
              AuthKeys.i.loggedIn: true,
              AuthKeys.i.loggedInTime: Entity.generateTimeMills,
            },
          ).then((value) {
            return emit(AuthResponse.authenticated(
              value,
              msg: msg.signInWithEmail.done,
              provider: AuthProviders.guest,
              type: AuthType.none,
            ));
          });
        } else {
          return emit(AuthResponse.failure(
            msg.authorization,
            provider: AuthProviders.guest,
            type: AuthType.none,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.guest,
          type: AuthType.none,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithEmail.failure ?? error,
        provider: AuthProviders.guest,
        type: AuthType.none,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
  }) async {
    try {
      emit(const AuthResponse.loading(
        AuthProviders.biometric,
        AuthType.biometric,
      ));
      final user = await _auth;
      if (user != null && user.isBiometric) {
        final response = await authHandler.signInWithBiometric(config: config);
        if (response.isSuccessful) {
          final token = user.accessToken;
          final provider = AuthProviders.from(user.provider);
          var current = Response<UserCredential>();
          if ((user.email ?? user.username ?? "").isNotEmpty &&
              (user.password ?? '').isNotEmpty) {
            if (provider.isEmail) {
              current = await authHandler.signInWithEmailNPassword(
                email: user.email ?? "",
                password: user.password ?? "",
              );
            } else if (provider.isUsername) {
              current = await authHandler.signInWithUsernameNPassword(
                username: user.username ?? "",
                password: user.password ?? "",
              );
            }
          } else if ((token ?? user.idToken ?? "").isNotEmpty) {
            if (provider.isApple) {
              current = await authHandler.signInWithCredential(
                credential: OAuthProvider("apple.com").credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
              );
            } else if (provider.isFacebook) {
              current = await authHandler.signInWithCredential(
                credential: FacebookAuthProvider.credential(token ?? ""),
              );
            } else if (provider.isGoogle) {
              current = await authHandler.signInWithCredential(
                credential: GoogleAuthProvider.credential(
                  idToken: user.idToken,
                  accessToken: token,
                ),
              );
            }
          }
          if (current.isSuccessful) {
            final updates = <String, dynamic>{
              AuthKeys.i.loggedIn: true,
              AuthKeys.i.loggedInTime: Entity.generateTimeMills,
            };
            return _update(id: user.id, updates: updates).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithBiometric.done,
                provider: AuthProviders.biometric,
                type: AuthType.biometric,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              current.exception,
              provider: AuthProviders.biometric,
              type: AuthType.biometric,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.biometric,
            type: AuthType.biometric,
          ));
        }
      } else {
        return emit(AuthResponse.unauthorized(
          msg: msg.signInWithBiometric.failure ?? error,
          provider: AuthProviders.biometric,
          type: AuthType.biometric,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithBiometric.failure ?? error,
        provider: AuthProviders.biometric,
        type: AuthType.biometric,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!AuthValidator.isValidEmail(email)) {
      return emit(AuthResponse.failure(
        msg.email,
        provider: AuthProviders.email,
        type: AuthType.login,
      ));
    } else if (!AuthValidator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        msg.password,
        provider: AuthProviders.email,
        type: AuthType.login,
      ));
    } else {
      try {
        emit(const AuthResponse.loading(AuthProviders.email, AuthType.login));
        final response = await authHandler.signInWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.email.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.mBiometric);
              return _update(
                id: user.id,
                initials: user.copy(biometric: biometric?.name).source,
                updates: {
                  ...user.extra ?? {},
                  AuthKeys.i.biometric: biometric?.name,
                  AuthKeys.i.loggedIn: true,
                  AuthKeys.i.loggedInTime: Entity.generateTimeMills,
                },
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signInWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.login,
                ));
              });
            } else {
              return _update(
                id: user.id,
                initials: user.source,
                updates: {
                  ...user.extra ?? {},
                  AuthKeys.i.loggedIn: true,
                  AuthKeys.i.loggedInTime: Entity.generateTimeMills,
                },
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signInWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.login,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.email,
              type: AuthType.login,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.email,
            type: AuthType.login,
          ));
        }
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signInWithEmail.failure ?? error,
          provider: AuthProviders.email,
          type: AuthType.login,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(PhoneAuthCredential credential)? onComplete,
    void Function(FirebaseAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
  }) async {
    final phone = authenticator.phone;
    if (!AuthValidator.isValidPhone(phone)) {
      return emit(AuthResponse.failure(
        msg.phoneNumber,
        provider: AuthProviders.phone,
        type: AuthType.otp,
      ));
    } else {
      try {
        authHandler.verifyPhoneNumber(
          phoneNumber: phone,
          forceResendingToken: int.tryParse(authenticator.accessToken ?? ""),
          multiFactorInfo: multiFactorInfo,
          multiFactorSession: multiFactorSession,
          timeout: timeout,
          onComplete: (PhoneAuthCredential credential) async {
            if (onComplete != null) {
              emit(const AuthResponse.message(
                "Verification done!",
                provider: AuthProviders.phone,
                type: AuthType.otp,
              ));
              onComplete(credential);
            } else {
              final verId = credential.verificationId;
              final code = credential.smsCode;
              if (verId != null && code != null) {
                signInByOtp(authenticator.otp(
                  token: verId,
                  smsCode: code,
                ));
              } else {
                emit(const AuthResponse.failure(
                  "Verification token or otp code not valid!",
                  provider: AuthProviders.phone,
                  type: AuthType.otp,
                ));
              }
            }
          },
          onCodeSent: (String verId, int? forceResendingToken) {
            emit(const AuthResponse.message(
              "Code sent to your device!",
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ));
            if (onCodeSent != null) {
              onCodeSent(verId, forceResendingToken);
            }
          },
          onFailed: (FirebaseAuthException exception) {
            emit(AuthResponse.failure(
              exception.message,
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ));
            if (onFailed != null) {
              onFailed(exception);
            }
          },
          onCodeAutoRetrievalTimeout: (String verId) {
            emit(const AuthResponse.failure(
              "Auto retrieval code timeout!",
              provider: AuthProviders.phone,
              type: AuthType.otp,
            ));
            if (onCodeAutoRetrievalTimeout != null) {
              onCodeAutoRetrievalTimeout(verId);
            }
          },
        );
        return emit(const AuthResponse.loading(
          AuthProviders.phone,
          AuthType.otp,
        ));
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signOut.failure ?? error,
          provider: AuthProviders.phone,
          type: AuthType.otp,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
  }) async {
    final token = authenticator.token;
    final code = authenticator.smsCode;
    if (!AuthValidator.isValidToken(token)) {
      return emit(AuthResponse.failure(
        msg.token,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      ));
    } else if (!AuthValidator.isValidSmsCode(code)) {
      return emit(AuthResponse.failure(
        msg.otp,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      ));
    } else {
      try {
        emit(const AuthResponse.loading(AuthProviders.phone, AuthType.phone));
        final credential = authenticator.credential;
        final response = await authHandler.signInWithCredential(
          credential: credential,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
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
              provider: AuthProviders.phone.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithPhone.done,
                provider: AuthProviders.phone,
                type: AuthType.phone,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.phone,
              type: AuthType.phone,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.phone,
            type: AuthType.phone,
          ));
        }
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signInWithPhone.failure ?? error,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!AuthValidator.isValidUsername(username)) {
      return emit(AuthResponse.failure(
        msg.username,
        provider: AuthProviders.username,
        type: AuthType.login,
      ));
    } else if (!AuthValidator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        msg.password,
        provider: AuthProviders.username,
        type: AuthType.login,
      ));
    } else {
      try {
        emit(const AuthResponse.loading(
          AuthProviders.username,
          AuthType.login,
        ));
        final response = await authHandler.signInWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.username.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.mBiometric);
              return _update(
                id: user.id,
                initials: user.copy(biometric: biometric?.name).source,
                updates: {
                  ...user.extra ?? {},
                  AuthKeys.i.biometric: biometric?.name,
                  AuthKeys.i.loggedIn: true,
                  AuthKeys.i.loggedInTime: Entity.generateTimeMills,
                },
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signInWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.login,
                ));
              });
            } else {
              return _update(
                id: user.id,
                initials: user.source,
                updates: {
                  ...user.extra ?? {},
                  AuthKeys.i.loggedIn: true,
                  AuthKeys.i.loggedInTime: Entity.generateTimeMills,
                },
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signInWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.login,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.username,
              type: AuthType.login,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.username,
            type: AuthType.login,
          ));
        }
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signInWithUsername.failure ?? error,
          provider: AuthProviders.username,
          type: AuthType.login,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    final email = authenticator.email;
    final password = authenticator.password;
    if (!AuthValidator.isValidEmail(email)) {
      return emit(AuthResponse.failure(
        msg.email,
        provider: AuthProviders.email,
        type: AuthType.register,
      ));
    } else if (!AuthValidator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        msg.password,
        provider: AuthProviders.email,
        type: AuthType.register,
      ));
    } else {
      try {
        emit(const AuthResponse.loading(
          AuthProviders.email,
          AuthType.register,
        ));
        final response = await authHandler.signUpWithEmailNPassword(
          email: email,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final creationTime = Entity.generateTimeMills;
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.email.name,
              loggedIn: true,
              loggedInTime: creationTime,
              timeMills: creationTime,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.mBiometric);
              return _update(
                id: user.id,
                initials: user.copy(biometric: biometric?.name).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signUpWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.register,
                ));
              });
            } else {
              return _update(id: user.id, initials: user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signUpWithEmail.done,
                  provider: AuthProviders.email,
                  type: AuthType.register,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.email,
              type: AuthType.register,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.email,
            type: AuthType.register,
          ));
        }
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signUpWithEmail.failure ?? error,
          provider: AuthProviders.email,
          type: AuthType.register,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) async {
    final username = authenticator.username;
    final password = authenticator.password;
    if (!AuthValidator.isValidUsername(username)) {
      return emit(AuthResponse.failure(
        msg.username,
        provider: AuthProviders.username,
        type: AuthType.register,
      ));
    } else if (!AuthValidator.isValidPassword(password)) {
      return emit(AuthResponse.failure(
        msg.password,
        provider: AuthProviders.username,
        type: AuthType.register,
      ));
    } else {
      try {
        emit(const AuthResponse.loading(
          AuthProviders.username,
          AuthType.register,
        ));
        final response = await authHandler.signUpWithUsernameNPassword(
          username: username,
          password: password,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final creationTime = Entity.generateTimeMills;
            final user = authenticator.copy(
              id: result.uid,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.username.name,
              loggedIn: true,
              loggedInTime: creationTime,
              timeMills: creationTime,
            );
            if (onBiometric != null) {
              final biometric = await onBiometric(user.mBiometric);
              return _update(
                id: user.id,
                initials: user.copy(biometric: biometric?.name).source,
              ).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signUpWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.register,
                ));
              });
            } else {
              return _update(id: user.id, initials: user.source).then((value) {
                return emit(AuthResponse.authenticated(
                  value,
                  msg: msg.signUpWithUsername.done,
                  provider: AuthProviders.username,
                  type: AuthType.register,
                ));
              });
            }
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.username,
              type: AuthType.register,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            response.exception,
            provider: AuthProviders.username,
            type: AuthType.register,
          ));
        }
      } catch (error) {
        return emit(AuthResponse.failure(
          msg.signUpWithUsername.failure ?? error,
          provider: AuthProviders.username,
          type: AuthType.register,
        ));
      }
    }
  }

  @override
  Future<AuthResponse<T>> signOut([
    AuthProviders? provider,
  ]) async {
    try {
      provider ??= (await _auth)?.mProvider;
      emit(AuthResponse.loading(provider, AuthType.logout));
      final response = await authHandler.signOut(provider);
      if (response.isSuccessful) {
        return _auth.then((data) async {
          if (data != null) {
            await update({
              AuthKeys.i.loggedIn: false,
              AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
            });
            if (data.isBiometric) {
              return _update(
                id: data.id,
                updates: {
                  ...data.extra ?? {},
                  AuthKeys.i.loggedIn: false,
                  AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
                },
              ).then((value) {
                return emit(AuthResponse.unauthenticated(
                  msg: msg.signOut.done,
                  provider: provider,
                  type: AuthType.logout,
                ));
              });
            } else {
              return _delete().then((value) {
                return emit(AuthResponse.unauthenticated(
                  msg: msg.signOut.done,
                  provider: provider,
                  type: AuthType.logout,
                ));
              });
            }
          } else {
            return emit(AuthResponse.unauthenticated(
              msg: msg.signOut.done,
              provider: provider,
              type: AuthType.logout,
            ));
          }
        });
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: provider,
          type: AuthType.logout,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signOut.failure ?? error,
        provider: provider,
        type: AuthType.logout,
      ));
    }
  }

  @override
  Future<T?> update(Map<String, dynamic> data) {
    return backupHandler.update(data).then((value) {
      return auth.then((update) {
        _emitUser(update);
        return update;
      });
    });
  }

  Future<T?> _update({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool updateMode = false,
  }) {
    return backupHandler
        .save(
      id: id,
      initials: initials,
      cacheUpdateMode: updateMode,
      updates: updates,
    )
        .then((value) {
      return _auth.then((update) {
        _emitUser(update);
        return update;
      });
    });
  }

  @override
  Future<AuthResponse> verifyPhoneByOtp(OtpAuthenticator authenticator) async {
    final token = authenticator.token;
    final code = authenticator.smsCode;
    if (!AuthValidator.isValidToken(token)) {
      return AuthResponse.failure(
        msg.token,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      );
    } else if (!AuthValidator.isValidSmsCode(code)) {
      return AuthResponse.failure(
        msg.otp,
        provider: AuthProviders.phone,
        type: AuthType.phone,
      );
    } else {
      try {
        final credential = authenticator.credential;
        final response = await authHandler.signInWithCredential(
          credential: credential,
        );
        if (response.isSuccessful) {
          final result = response.data?.user;
          if (result != null) {
            final user = authenticator.copy(
              id: result.uid,
              accessToken: credential.accessToken,
              idToken: credential.token != null ? "${credential.token}" : null,
              email: result.email,
              name: result.displayName,
              phone: result.phoneNumber,
              photo: result.photoURL,
              provider: AuthProviders.phone.name,
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
          } else {
            return AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.phone,
              type: AuthType.phone,
            );
          }
        } else {
          return AuthResponse.failure(
            response.exception,
            provider: AuthProviders.phone,
            type: AuthType.phone,
          );
        }
      } catch (error) {
        return AuthResponse.failure(
          msg.signInWithPhone.failure ?? error,
          provider: AuthProviders.phone,
          type: AuthType.phone,
        );
      }
    }
  }

  // OAUTH
  @override
  Future<AuthResponse<T>> signInWithApple({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.apple, AuthType.oauth));
      final response = await authHandler.signInWithApple();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.apple.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithApple.done,
                provider: AuthProviders.apple,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.apple,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.apple,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.apple,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithApple.failure ?? error,
        provider: AuthProviders.apple,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithFacebook({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.facebook, AuthType.oauth));
      final response = await authHandler.signInWithFacebook();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.facebook.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithFacebook.done,
                provider: AuthProviders.facebook,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.facebook,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.facebook,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.facebook,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithFacebook.failure ?? error,
        provider: AuthProviders.facebook,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithGameCenter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(
        AuthProviders.gameCenter,
        AuthType.oauth,
      ));
      final response = await authHandler.signInWithGameCenter();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.gameCenter.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.gameCenter,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.gameCenter,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.gameCenter,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.gameCenter,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.gameCenter,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithGithub({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.github, AuthType.oauth));
      final response = await authHandler.signInWithGithub();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.github.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.github,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.github,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.github,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.github,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.github,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithGoogle({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.google, AuthType.oauth));
      final response = await authHandler.signInWithGoogle();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.google.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGoogle.done,
                provider: AuthProviders.google,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.google,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.google,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.google,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGoogle.failure ?? error,
        provider: AuthProviders.google,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithMicrosoft({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.microsoft, AuthType.oauth));
      final response = await authHandler.signInWithMicrosoft();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.microsoft.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.microsoft,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.microsoft,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.microsoft,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.microsoft,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.microsoft,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithPlayGames({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.playGames, AuthType.oauth));
      final response = await authHandler.signInWithPlayGames();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.playGames.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.playGames,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.playGames,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.playGames,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.playGames,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.playGames,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithSAML({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.saml, AuthType.oauth));
      final response = await authHandler.signInWithSAML();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.saml.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.saml,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.saml,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.saml,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.saml,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.saml,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithTwitter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.twitter, AuthType.oauth));
      final response = await authHandler.signInWithTwitter();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.twitter.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.twitter,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.twitter,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.twitter,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.twitter,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.twitter,
        type: AuthType.oauth,
      ));
    }
  }

  @override
  Future<AuthResponse<T>> signInWithYahoo({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) async {
    try {
      emit(const AuthResponse.loading(AuthProviders.yahoo, AuthType.oauth));
      final response = await authHandler.signInWithYahoo();
      final raw = response.data;
      if (raw != null && raw.credential != null) {
        final current = await authHandler.signInWithCredential(
          credential: raw.credential!,
        );
        if (current.isSuccessful) {
          final result = current.data?.user;
          if (result != null) {
            final user = (authenticator ?? Authenticator.oauth()).copy(
              id: result.uid,
              accessToken: storeToken ? raw.accessToken : null,
              idToken: storeToken ? raw.idToken : null,
              email: raw.email ?? result.email,
              name: raw.name ?? result.displayName,
              phone: result.phoneNumber,
              photo: raw.photo ?? result.photoURL,
              provider: AuthProviders.yahoo.name,
              loggedIn: true,
              loggedInTime: Entity.generateTimeMills,
              verified: true,
            );
            return _update(
              id: user.id,
              initials: user.source,
              updates: {
                ...user.extra ?? {},
                AuthKeys.i.loggedIn: true,
                AuthKeys.i.loggedInTime: Entity.generateTimeMills,
              },
            ).then((value) {
              return emit(AuthResponse.authenticated(
                value,
                msg: msg.signInWithGithub.done,
                provider: AuthProviders.yahoo,
                type: AuthType.oauth,
              ));
            });
          } else {
            return emit(AuthResponse.failure(
              msg.authorization,
              provider: AuthProviders.yahoo,
              type: AuthType.oauth,
            ));
          }
        } else {
          return emit(AuthResponse.failure(
            current.exception,
            provider: AuthProviders.yahoo,
            type: AuthType.oauth,
          ));
        }
      } else {
        return emit(AuthResponse.failure(
          response.exception,
          provider: AuthProviders.yahoo,
          type: AuthType.oauth,
        ));
      }
    } catch (error) {
      return emit(AuthResponse.failure(
        msg.signInWithGithub.failure ?? error,
        provider: AuthProviders.yahoo,
        type: AuthType.oauth,
      ));
    }
  }
}
