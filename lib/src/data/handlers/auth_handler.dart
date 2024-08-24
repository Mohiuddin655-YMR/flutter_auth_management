import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_entity/flutter_entity.dart';

import '../../delegates/user.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/handlers/auth_handler.dart';
import '../../services/sources/auth_data_source.dart';
import '../repositories/auth_repository.dart';

class AuthHandlerImpl extends AuthHandler {
  AuthHandlerImpl(AuthDataSource source) : super(AuthRepositoryImpl(source));

  const AuthHandlerImpl.fromRepository(super.repository);

  @override
  auth.User? get user => repository.user;

  @override
  IUserDelegate get userDelegate => repository.userDelegate;

  @override
  Future<bool> isSignIn([AuthProviders? provider]) {
    return repository.isSignIn(provider);
  }

  @override
  Future<Response<auth.UserCredential>> signInAnonymously() {
    return repository.signInAnonymously();
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    return repository.signInWithApple();
  }

  @override
  Future<Response<bool>> signInWithBiometric({BiometricConfig? config}) {
    return repository.signInWithBiometric(config: config);
  }

  @override
  Future<Response<auth.UserCredential>> signInWithCredential({
    required auth.AuthCredential credential,
  }) {
    return repository.signInWithCredential(credential: credential);
  }

  @override
  Future<Response<auth.UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmailNPassword(
        email: email, password: password);
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    return repository.signInWithFacebook();
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() {
    return repository.signInWithGameCenter();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    return repository.signInWithGithub();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    return repository.signInWithGoogle();
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() {
    return repository.signInWithMicrosoft();
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() {
    return repository.signInWithPlayGames();
  }

  @override
  Future<Response<Credential>> signInWithSAML() {
    return repository.signInWithSAML();
  }

  @override
  Future<Response<Credential>> signInWithTwitter() {
    return repository.signInWithTwitter();
  }

  @override
  Future<Response<auth.UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return repository.signInWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<Credential>> signInWithYahoo() {
    return repository.signInWithYahoo();
  }

  @override
  Future<Response<Auth<AuthKeys>>> signOut([AuthProviders? provider]) {
    return repository.signOut(provider);
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmailNPassword(
        email: email, password: password);
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return repository.signUpWithUsernameNPassword(
      username: username,
      password: password,
    );
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
  }) {
    return repository.verifyPhoneNumber(
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
    );
  }
}
