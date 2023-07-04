part of 'sources.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final ConnectivityProvider connectivity;
  final FacebookAuth facebookAuth;
  final FirebaseAuth firebaseAuth;
  final LocalAuthentication localAuth;
  final GoogleSignIn googleAuth;

  Future<bool> get isConnected async => await connectivity.isConnected;

  Future<bool> get isDisconnected async => !(await isConnected);

  AuthDataSourceImpl({
    ConnectivityProvider? connectivity,
    FacebookAuth? facebookAuth,
    FirebaseAuth? firebaseAuth,
    LocalAuthentication? localAuth,
    GoogleSignIn? googleAuth,
  })  : connectivity = connectivity ?? ConnectivityProvider.I,
        facebookAuth = facebookAuth ?? FacebookAuth.i,
        firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        localAuth = localAuth ?? LocalAuthentication(),
        googleAuth = googleAuth ?? GoogleSignIn(scopes: ['email']);

  @override
  String? get uid => user?.uid;

  @override
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Future<bool> isSignIn([AuthProvider? provider]) async {
    if (provider != null) {
      switch (provider) {
        case AuthProvider.email:
        case AuthProvider.username:
        case AuthProvider.phone:
          return firebaseAuth.currentUser != null;
        case AuthProvider.facebook:
          return (await facebookAuth.accessToken) != null;
        case AuthProvider.google:
          return googleAuth.isSignedIn();
        case AuthProvider.apple:
        case AuthProvider.biometric:
        case AuthProvider.github:
        case AuthProvider.twitter:
        case AuthProvider.custom:
          return false;
      }
    }
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<Response> signOut([AuthProvider? provider]) async {
    final response = Response();
    try {
      if (await isConnected) {
        if (provider != null) {
          switch (provider) {
            case AuthProvider.email:
            case AuthProvider.phone:
            case AuthProvider.username:
              await firebaseAuth.signOut();
              break;
            case AuthProvider.facebook:
              await facebookAuth.logOut();
              break;
            case AuthProvider.google:
              await googleAuth.signOut();
              break;
            case AuthProvider.apple:
            case AuthProvider.biometric:
            case AuthProvider.github:
            case AuthProvider.twitter:
            case AuthProvider.custom:
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
    return response.withData(null);
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
        return response.withData(Credential(
          credential: AppleAuthProvider.credential(result.authorizationCode),
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
  Future<Response<bool>> signInWithBiometric() async {
    final response = Response<bool>();
    try {
      if (!await localAuth.isDeviceSupported()) {
        return response.withException(
          "Device isn't supported!",
          status: Status.notSupported,
        );
      } else {
        if (await localAuth.canCheckBiometrics) {
          final authenticated = await localAuth.authenticate(
            localizedReason:
                'Scan your fingerprint (or face or whatever) to authenticate',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );
          if (authenticated) {
            return response.withData(true);
          } else {
            return response.withException(
              "Biometric matching failed!",
              status: Status.notFound,
            );
          }
        } else {
          return response.withException(
            "Can not check bio metrics!",
            status: Status.undetected,
          );
        }
      }
    } catch (_) {
      return response.withException(_, status: Status.failure);
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
  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInWithCredential(credential);
      return response.withData(result, message: "Sign up successful!");
    } on FirebaseAuthException catch (_) {
      return response.withException(_.message, status: Status.failure);
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
}
