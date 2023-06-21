part of 'handlers.dart';

abstract class AuthHandler {
  final AuthRepository repository;

  const AuthHandler({
    required this.repository,
  });

  String? get uid;

  User? get user;

  Future<bool> isSignIn([AuthProvider? provider]);

  Future<Response<void>> signOut([AuthProvider? provider]);

  Future<Response<Credential>> signInWithApple();

  Future<Response<bool>> signInWithBiometric();

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<UserCredential>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  });

  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });
}
