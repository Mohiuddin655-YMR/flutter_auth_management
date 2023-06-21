part of 'sources.dart';

abstract class AuthDataSource {
  Future<bool> isSignIn([AuthProvider? provider]);

  Future<Response> signOut([AuthProvider? provider]);

  String? get uid;

  User? get user;

  Future<Response<UserCredential>> signUpWithCredential({
    required AuthCredential credential,
  });

  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<Credential>> signInWithApple();

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<bool>> signInWithBiometric();
}
