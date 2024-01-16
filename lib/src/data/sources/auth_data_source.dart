import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_andomie/core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/sources/auth_data_source.dart';

class AuthDataSourceImpl extends AuthDataSource {
  ConnectivityProvider? _connectivity;
  FacebookAuth? _facebookAuth;
  FirebaseAuth? _firebaseAuth;
  LocalAuthentication? _localAuth;
  GoogleSignIn? _googleAuth;

  ConnectivityProvider get connectivity =>
      _connectivity ??= ConnectivityProvider.I;

  FacebookAuth get facebookAuth => _facebookAuth ??= FacebookAuth.i;

  FirebaseAuth get firebaseAuth => _firebaseAuth ??= FirebaseAuth.instance;

  LocalAuthentication get localAuth => _localAuth ??= LocalAuthentication();

  GoogleSignIn get googleAuth =>
      _googleAuth ??= GoogleSignIn(scopes: ['email']);

  Future<bool> get isConnected async => await connectivity.isConnected;

  Future<bool> get isDisconnected async => !(await isConnected);

  AuthDataSourceImpl({
    ConnectivityProvider? connectivity,
    FacebookAuth? facebookAuth,
    FirebaseAuth? firebaseAuth,
    LocalAuthentication? localAuth,
    GoogleSignIn? googleAuth,
  })  : _connectivity = connectivity,
        _facebookAuth = facebookAuth,
        _firebaseAuth = firebaseAuth,
        _localAuth = localAuth,
        _googleAuth = googleAuth;

  @override
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Future<Response> get delete async {
    final response = Response();
    if (user != null) {
      try {
        return user!.delete().then((value) {
          return response.withStatus(
            Status.ok,
            message: "Account delete successful!",
          );
        });
      } on FirebaseAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException(
        "User isn't valid!",
        status: Status.invalid,
      );
    }
  }

  @override
  Future<bool> isSignIn([AuthProviders? provider]) async {
    if (provider != null) {
      switch (provider) {
        case AuthProviders.email:
        case AuthProviders.username:
        case AuthProviders.phone:
          return firebaseAuth.currentUser != null;
        case AuthProviders.facebook:
          return (await facebookAuth.accessToken) != null;
        case AuthProviders.google:
          return googleAuth.isSignedIn();
        case AuthProviders.apple:
        case AuthProviders.biometric:
        case AuthProviders.github:
        case AuthProviders.twitter:
        case AuthProviders.none:
          return false;
      }
    }
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<Response<Credential>> signInWithApple() async {
    final response = Response<Credential>();
    try {
      final result = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (result.identityToken != null) {
        final credential = OAuthProvider("apple.com").credential(
          idToken: result.identityToken,
          accessToken: result.authorizationCode,
        );

        return response.withData(Credential(
          credential: credential,
          accessToken: result.authorizationCode,
          idToken: result.identityToken,
          id: result.userIdentifier,
          email: result.email,
          name: result.givenName ?? result.familyName,
        ));
      } else {
        return response.withException('Token not valid!', status: Status.error);
      }
    } on SignInWithAppleAuthorizationException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) async {
    final response = Response<bool>();
    final mConfig = config ?? const BiometricConfig();
    try {
      if (!await localAuth.isDeviceSupported()) {
        return response.withException(
          mConfig.deviceException,
          status: Status.notSupported,
        );
      } else {
        if (await localAuth.canCheckBiometrics) {
          final authenticated = await localAuth.authenticate(
            localizedReason: mConfig.localizedReason,
            authMessages: mConfig.authMessages,
            options: mConfig.options,
          );
          if (authenticated) {
            return response.withData(true);
          } else {
            return response.withException(
              mConfig.failureException,
              status: Status.notFound,
            );
          }
        } else {
          return response.withException(
            mConfig.checkingException,
            status: Status.undetected,
          );
        }
      }
    } catch (_) {
      return response.withException(_, status: Status.failure);
    }
  }

  @override
  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInWithCredential(credential);
      return response.withData(result, message: "Sign in successful!");
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign in successful!");
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() async {
    final response = Response<Credential>();
    try {
      final token = await facebookAuth.accessToken;
      LoginResult? result;

      result = token == null
          ? await facebookAuth.login(permissions: ['public_profile', 'email'])
          : null;

      final status = result?.status ?? LoginStatus.failed;

      if (token != null || status == LoginStatus.success) {
        final accessToken = result?.accessToken ?? token;
        if (accessToken != null) {
          final credential = FacebookAuthProvider.credential(accessToken.token);
          final fbData = await facebookAuth.getUserData();
          return response.withData(Credential.fromMap(fbData).copy(
            accessToken: accessToken.token,
            credential: credential,
          ));
        } else {
          return response.withException(
            'Token not valid!',
            status: Status.error,
          );
        }
      } else {
        return response.withException('Token not valid!', status: Status.error);
      }
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signInWithGithub() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (_) {
      return response.withException(_, status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() async {
    final response = Response<Credential>();
    try {
      GoogleSignInAccount? result;
      final auth = googleAuth;
      final isSignedIn = await auth.isSignedIn();
      if (isSignedIn) {
        result = await auth.signInSilently();
      } else {
        result = await auth.signIn();
      }
      if (result != null) {
        final authentication = await result.authentication;
        final idToken = authentication.idToken;
        final accessToken = authentication.accessToken;
        if (accessToken != null || idToken != null) {
          final receivedData = auth.currentUser;
          return response.withData(Credential(
            id: receivedData?.id,
            email: receivedData?.email,
            name: receivedData?.displayName,
            photo: receivedData?.photoUrl,
            accessToken: accessToken,
            idToken: idToken,
            credential: GoogleAuthProvider.credential(
              idToken: idToken,
              accessToken: accessToken,
            ),
          ));
        } else {
          return response.withException(
            'Token not valid!',
            status: Status.error,
          );
        }
      } else {
        return response.withException('Sign in failed!', status: Status.error);
      }
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    var mail = Converter.toMail(username, "user", "org");
    if (Validator.isValidEmail(mail)) {
      try {
        final result = await firebaseAuth.signInWithEmailAndPassword(
          email: mail ?? "example@user.org",
          password: password,
        );
        return response.withData(result, message: "Sign in successful!");
      } on FirebaseAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException("Username isn't valid!");
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign up successful!");
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    var mail = Converter.toMail(username, "user", "org");
    if (Validator.isValidEmail(mail)) {
      try {
        final result = await firebaseAuth.createUserWithEmailAndPassword(
          email: mail ?? "example@user.org",
          password: password,
        );
        return response.withData(result, message: "Sign up successful!");
      } on FirebaseAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException("Username isn't valid!");
    }
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) async {
    final response = Response<Auth>();
    var data = Auth.fromUser(user);
    try {
      if (await isConnected) {
        if (provider != null) {
          switch (provider) {
            case AuthProviders.email:
            case AuthProviders.phone:
            case AuthProviders.username:
              await firebaseAuth.signOut();
              break;
            case AuthProviders.facebook:
              await facebookAuth.logOut();
              break;
            case AuthProviders.google:
              await googleAuth.signOut();
              break;
            case AuthProviders.apple:
            case AuthProviders.biometric:
            case AuthProviders.github:
            case AuthProviders.twitter:
            case AuthProviders.none:
              break;
          }
        } else {
          await firebaseAuth.signOut();
          if (await googleAuth.isSignedIn()) {
            googleAuth.disconnect();
            googleAuth.signOut();
          }
        }
      } else {
        return response.withStatus(Status.networkError);
      }
    } catch (_) {
      return response.withException(_, status: Status.failure);
    }
    return response.withData(data);
  }

  @override
  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(PhoneAuthCredential credential) onComplete,
    required void Function(FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) async {
    final response = Response<void>();
    if (Validator.isValidPhone(phoneNumber)) {
      try {
        firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken: forceResendingToken,
          multiFactorInfo: multiFactorInfo,
          multiFactorSession: multiFactorSession,
          timeout: timeout,
          verificationCompleted: onComplete,
          verificationFailed: onFailed,
          codeSent: onCodeSent,
          codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
        );
        return response;
      } on FirebaseAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException("Phone number isn't valid!");
    }
  }
}
