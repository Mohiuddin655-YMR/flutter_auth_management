part of 'handlers.dart';

abstract class AuthHandler {
  final AuthRepository repository;

  const AuthHandler(this.repository);

  String? get uid;

  User? get user;

  Future<bool> isSignIn([AuthType? provider]);

  Future<Response<Authorizer>> signOut([AuthType? provider]);

  Future<Response<Credential>> signInWithApple();

  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  });

  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  });

  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response> delete(User? user);
}
