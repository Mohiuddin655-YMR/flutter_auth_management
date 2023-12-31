part of 'handlers.dart';

class AuthHandlerImpl extends AuthHandler {
  AuthHandlerImpl({
    AuthDataSource? source,
  }) : super(AuthRepositoryImpl(source: source ?? AuthDataSourceImpl()));

  AuthHandlerImpl.fromRepository({
    AuthRepository? repository,
  }) : super(repository ?? AuthRepositoryImpl(source: AuthDataSourceImpl()));

  @override
  Future<bool> isSignIn([AuthType? provider]) {
    try {
      return repository.isSignIn(provider);
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    try {
      return repository.signInWithApple();
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    try {
      return repository.signInWithBiometric(config: config);
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository.signInWithEmailNPassword(
        email: email,
        password: password,
      );
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    try {
      return repository.signInWithFacebook();
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    try {
      return repository.signInWithGithub();
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    try {
      return repository.signInWithGoogle();
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository.signInWithUsernameNPassword(
        username: username,
        password: password,
      );
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  }) async {
    try {
      return repository.signUpWithCredential(
        credential: credential,
      );
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository.signUpWithEmailNPassword(
        email: email,
        password: password,
      );
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository.signUpWithUsernameNPassword(
        username: username,
        password: password,
      );
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response<Authorizer>> signOut([AuthType? provider]) {
    try {
      return repository.signOut(provider);
    } catch (_) {
      return Future.error("$_");
    }
  }

  @override
  Future<Response> delete(User? user) => repository.delete(user);

  @override
  String? get uid => repository.uid;

  @override
  User? get user => repository.user;
}
