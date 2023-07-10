part of 'repositories.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource source;

  AuthRepositoryImpl({
    required this.source,
  });

  @override
  String? get uid => source.uid;

  @override
  User? get user => source.user;

  @override
  Future<bool> isSignIn([AuthProvider? provider]) => source.isSignIn();

  @override
  Future<Response<Auth>> signOut([AuthProvider? provider]) => source.signOut();

  @override
  Future<Response<Credential>> signInWithApple() {
    return source.signInWithApple();
  }

  @override
  Future<Response<bool>> signInWithBiometric() {
    return source.signInWithBiometric();
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return source.signInWithEmailNPassword(email: email, password: password);
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    return source.signInWithFacebook();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    return source.signInWithGithub();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    return source.signInWithGoogle();
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signInWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  }) {
    return source.signUpWithCredential(credential: credential);
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return source.signUpWithEmailNPassword(email: email, password: password);
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signUpWithUsernameNPassword(
      username: username,
      password: password,
    );
  }
}
