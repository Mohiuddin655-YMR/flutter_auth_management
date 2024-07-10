import '../../../core.dart';
import '../../utils/connectivity.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final Authorizer authorizer;
  final OAuthDelegates? _delegates;
  ConnectionService? _connectivity;

  OAuthDelegates get delegates => _delegates ?? const OAuthDelegates();

  IAppleAuthDelegate get appleAuth {
    if (delegates.appleAuthDelegate != null) {
      return delegates.appleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IAppleAuthDelegate");
    }
  }

  IFacebookAuthDelegate get facebookAuth {
    if (delegates.facebookAuthDelegate != null) {
      return delegates.facebookAuthDelegate!;
    } else {
      throw const AuthDelegateException("IFacebookAuthDelegate");
    }
  }

  IBiometricAuthDelegate get localAuth {
    if (delegates.biometricAuthDelegate != null) {
      return delegates.biometricAuthDelegate!;
    } else {
      throw const AuthDelegateException("IBiometricAuthDelegate");
    }
  }

  IGoogleAuthDelegate get googleAuth {
    if (delegates.googleAuthDelegate != null) {
      return delegates.googleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IGoogleAuthDelegate");
    }
  }

  ConnectionService get connectivity => _connectivity ??= ConnectionService.I;

  Future<bool> get isConnected async => await connectivity.isConnected;

  Future<bool> get isDisconnected async => !(await isConnected);

  AuthDataSourceImpl({
    required this.authorizer,
    OAuthDelegates? delegates,
  }) : _delegates = delegates;

  @override
  IUser? get user => authorizer.currentUser;

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
      } on IAuthException catch (_) {
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
          return authorizer.currentUser != null;
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
    return authorizer.currentUser != null;
  }

  @override
  Future<Response<Credential>> signInWithApple() async {
    final response = Response<Credential>();
    try {
      final result = await appleAuth.getAppleIDCredential(
        scopes: [
          IAppleIDAuthorizationScopes.email,
          IAppleIDAuthorizationScopes.fullName,
        ],
      );

      if (result.identityToken != null) {
        final credential = IOAuthProvider("apple.com").credential(
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
    } catch (_) {
      return response.withException(_.toString(), status: Status.failure);
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
  Future<Response<IUserCredential>> signInWithCredential({
    required IAuthCredential credential,
  }) async {
    final response = Response<IUserCredential>();
    try {
      final result = await authorizer.signInWithCredential(credential);
      return response.withData(result, message: "Sign in successful!");
    } on IAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<IUserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<IUserCredential>();
    try {
      final result = await authorizer.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign in successful!");
    } on IAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() async {
    final response = Response<Credential>();
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
          final credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final fbData = await facebookAuth.getUserData();
          return response.withData(Credential.fromMap(fbData).copy(
            accessToken: accessToken.tokenString,
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
    } catch (_) {
      return response.withException(_.toString(), status: Status.failure);
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
    } catch (_) {
      return response.withException(_.toString(), status: Status.failure);
    }
  }

  @override
  Future<Response<IUserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    final response = Response<IUserCredential>();
    var mail = AuthConverter.toMail(username, "user", "org");
    if (AuthValidator.isValidEmail(mail)) {
      try {
        final result = await authorizer.signInWithEmailAndPassword(
          email: mail ?? "example@user.org",
          password: password,
        );
        return response.withData(result, message: "Sign in successful!");
      } on IAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException("Username isn't valid!");
    }
  }

  @override
  Future<Response<IUserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<IUserCredential>();
    try {
      final result = await authorizer.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign up successful!");
    } on IAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
    }
  }

  @override
  Future<Response<IUserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    final response = Response<IUserCredential>();
    var mail = AuthConverter.toMail(username, "user", "org");
    if (AuthValidator.isValidEmail(mail)) {
      try {
        final result = await authorizer.createUserWithEmailAndPassword(
          email: mail ?? "example@user.org",
          password: password,
        );
        return response.withData(result, message: "Sign up successful!");
      } on IAuthException catch (_) {
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
              await authorizer.signOut();
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
          await authorizer.signOut();
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
    IPhoneMultiFactorInfo? multiFactorInfo,
    IMultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(IPhoneAuthCredential credential) onComplete,
    required void Function(IAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) async {
    final response = Response();
    if (AuthValidator.isValidPhone(phoneNumber)) {
      try {
        authorizer.verifyPhoneNumber(
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
      } on IAuthException catch (_) {
        return response.withException(_.message, status: Status.failure);
      }
    } else {
      return response.withException("Phone number isn't valid!");
    }
  }
}
