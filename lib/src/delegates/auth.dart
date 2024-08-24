import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart' show GoogleAuthProvider;
import 'package:flutter_entity/entity.dart';

import '../core/converter.dart';
import '../exceptions/oauth.dart';
import '../models/auth.dart';
import '../models/auth_providers.dart';
import '../models/biometric_config.dart';
import '../models/credential.dart';

abstract class IAuthDelegate {
  final IAppleAuthDelegate? appleAuthDelegate;
  final IBiometricAuthDelegate? biometricAuthDelegate;
  final IFacebookAuthDelegate? facebookAuthDelegate;
  final IGoogleAuthDelegate? googleAuthDelegate;

  const IAuthDelegate({
    this.appleAuthDelegate,
    this.biometricAuthDelegate,
    this.facebookAuthDelegate,
    this.googleAuthDelegate,
  });

  Future<bool> isSignIn([AuthProviders? provider]);

  Future<Response<auth.UserCredential>> signInAnonymously();

  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  });

  Future<Response<auth.UserCredential>> signInWithCredential({
    required auth.AuthCredential credential,
  });

  Future<Response<auth.UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<auth.UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<auth.UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<auth.UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<Auth>> signOut([AuthProviders? provider]);

  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    auth.PhoneMultiFactorInfo? multiFactorInfo,
    auth.MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(auth.PhoneAuthCredential credential) onComplete,
    required void Function(auth.FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  });

  Future<Response<Credential>> signInWithApple();

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGameCenter();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<Credential>> signInWithMicrosoft();

  Future<Response<Credential>> signInWithPlayGames();

  Future<Response<Credential>> signInWithSAML();

  Future<Response<Credential>> signInWithTwitter();

  Future<Response<Credential>> signInWithYahoo();
}

class AuthDelegate extends IAuthDelegate {
  AuthDelegate({
    super.appleAuthDelegate,
    super.biometricAuthDelegate,
    super.facebookAuthDelegate,
    super.googleAuthDelegate,
  });

  auth.FirebaseAuth? _firebaseAuth;

  auth.FirebaseAuth get firebaseAuth {
    return _firebaseAuth ??= auth.FirebaseAuth.instance;
  }

  IAppleAuthDelegate get appleAuth {
    if (appleAuthDelegate != null) {
      return appleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IAppleAuthDelegate");
    }
  }

  IFacebookAuthDelegate get facebookAuth {
    if (facebookAuthDelegate != null) {
      return facebookAuthDelegate!;
    } else {
      throw const AuthDelegateException("IFacebookAuthDelegate");
    }
  }

  IBiometricAuthDelegate get localAuth {
    if (biometricAuthDelegate != null) {
      return biometricAuthDelegate!;
    } else {
      throw const AuthDelegateException("IBiometricAuthDelegate");
    }
  }

  IGoogleAuthDelegate get googleAuth {
    if (googleAuthDelegate != null) {
      return googleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IGoogleAuthDelegate");
    }
  }

  @override
  Future<bool> isSignIn([AuthProviders? provider]) async {
    if (provider != null) {
      switch (provider) {
        // OAUTH
        case AuthProviders.apple:
          return false;
        case AuthProviders.facebook:
          return (await facebookAuth.accessToken) != null;
        case AuthProviders.gameCenter:
          return false;
        case AuthProviders.github:
          return false;
        case AuthProviders.google:
          return googleAuth.isSignedIn();
        case AuthProviders.microsoft:
          return false;
        case AuthProviders.playGames:
          return false;
        case AuthProviders.saml:
          return false;
        case AuthProviders.twitter:
          return false;
        case AuthProviders.yahoo:
          return false;
        // CUSTOM
        case AuthProviders.email:
        case AuthProviders.guest:
        case AuthProviders.username:
        case AuthProviders.phone:
          return firebaseAuth.currentUser != null;
        case AuthProviders.biometric:
        case AuthProviders.none:
          return false;
      }
    }
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<Response<auth.UserCredential>> signInAnonymously() async {
    try {
      final result = await firebaseAuth.signInAnonymously();
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign in successful!",
      );
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == "operation-not-allowed") {
        return Response(
          exception: "Anonymous auth hasn't been enabled for this project.",
          status: Status.notSupported,
        );
      }
      return Response(exception: e.message, status: Status.failure);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) async {
    final mConfig = config ?? const BiometricConfig();
    try {
      final bool check = await localAuth.canCheckBiometrics;
      final bool isSupportable = check || await localAuth.isDeviceSupported();
      if (!isSupportable) {
        return Response(
          exception: mConfig.deviceException,
          status: Status.notSupported,
        );
      } else {
        if (check) {
          final authenticated = await localAuth.authenticate(
            localizedReason: mConfig.localizedReason,
            authMessages: mConfig.authMessages,
            options: mConfig.options,
          );
          if (authenticated) {
            return Response(status: Status.ok, data: true);
          } else {
            return Response(
              exception: mConfig.failureException,
              status: Status.notFound,
            );
          }
        } else {
          return Response(
            exception: mConfig.checkingException,
            status: Status.undetected,
          );
        }
      }
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> signInWithCredential({
    required auth.AuthCredential credential,
  }) async {
    try {
      final result = await firebaseAuth.signInWithCredential(credential);
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign in successful!",
      );
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign in successful!",
      );
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    try {
      var mail = AuthConverter.toMail(username, "user", "org");
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign in successful!",
      );
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign up successful!",
      );
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    try {
      var mail = AuthConverter.toMail(username, "user", "org");
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign up successful!",
      );
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) async {
    try {
      var data = Auth.fromUser(auth.FirebaseAuth.instance.currentUser);
      if (provider != null) {
        switch (provider) {
          // OAUTH
          case AuthProviders.apple:
            break;
          case AuthProviders.facebook:
            await facebookAuth.logOut();
            break;
          case AuthProviders.gameCenter:
            break;
          case AuthProviders.github:
            break;
          case AuthProviders.google:
            if (await googleAuth.isSignedIn()) {
              googleAuth.disconnect();
              googleAuth.signOut();
            }
            break;
          case AuthProviders.microsoft:
            break;
          case AuthProviders.playGames:
            break;
          case AuthProviders.saml:
            break;
          case AuthProviders.twitter:
            break;
          case AuthProviders.yahoo:
            break;
          // CUSTOM
          case AuthProviders.biometric:
          case AuthProviders.guest:
          case AuthProviders.email:
          case AuthProviders.phone:
          case AuthProviders.username:
          case AuthProviders.none:
            break;
        }
      } else {
        if (await googleAuth.isSignedIn()) {
          googleAuth.disconnect();
          googleAuth.signOut();
        }
      }
      await firebaseAuth.signOut();
      return Response(status: Status.ok, data: data);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    auth.PhoneMultiFactorInfo? multiFactorInfo,
    auth.MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(auth.PhoneAuthCredential credential) onComplete,
    required void Function(auth.FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
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
      return Response(status: Status.ok);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithApple() async {
    try {
      final result = await appleAuth.getAppleIDCredential(
        scopes: [
          IAppleIDAuthorizationScopes.email,
          IAppleIDAuthorizationScopes.fullName,
        ],
      );

      if (result.identityToken != null) {
        final credential = auth.OAuthProvider("apple.com").credential(
          idToken: result.identityToken,
          accessToken: result.authorizationCode,
        );

        return Response(
          status: Status.ok,
          data: Credential(
            credential: credential,
            accessToken: result.authorizationCode,
            idToken: result.identityToken,
            id: result.userIdentifier,
            email: result.email,
            name: result.givenName ?? result.familyName,
          ),
        );
      } else {
        return Response(status: Status.invalid, exception: 'Token not valid!');
      }
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() async {
    try {
      final token = await facebookAuth.accessToken;
      IFacebookLoginResult? result;

      result = token == null
          ? await facebookAuth.login(permissions: ['public_profile', 'email'])
          : null;

      final status = result?.status ?? IFacebookLoginStatus.failed;

      if (token != null || status == IFacebookLoginStatus.success) {
        final accessToken = result?.accessToken ?? token;
        if (accessToken != null) {
          final credential = auth.FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final fbData = await facebookAuth.getUserData();
          return Response(
            status: Status.ok,
            data: Credential.fromMap(fbData).copy(
              accessToken: accessToken.tokenString,
              credential: credential,
            ),
          );
        } else {
          return Response(
            exception: 'Token not valid!',
            status: Status.invalid,
          );
        }
      } else {
        return Response(exception: 'Token not valid!', status: Status.invalid);
      }
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithGithub() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() async {
    try {
      IGoogleSignInAccount? result;
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
          return Response(
            status: Status.ok,
            data: Credential(
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
            ),
          );
        } else {
          return Response(
            exception: 'Token not valid!',
            status: Status.invalid,
          );
        }
      } else {
        return Response(status: Status.error, exception: 'Sign in failed!');
      }
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithSAML() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithTwitter() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithYahoo() async {
    try {
      return Response(status: Status.undefined);
    } on auth.FirebaseAuthException catch (error) {
      return Response(status: Status.failure, exception: error.message);
    } catch (error) {
      return Response(status: Status.failure, exception: error.toString());
    }
  }
}
