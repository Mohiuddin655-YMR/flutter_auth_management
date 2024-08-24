import 'package:auth_management/src/delegates/auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_entity/flutter_entity.dart';

import '../../delegates/user.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  const AuthRepositoryImpl(super.source);

  @override
  auth.User? get user => userDelegate.user;

  IAuthDelegate get authDelegate => source.authDelegate;

  @override
  IUserDelegate get userDelegate => source.userDelegate;

  @override
  Future<bool> isSignIn([AuthProviders? provider]) {
    return authDelegate.isSignIn(provider);
  }

  @override
  Future<Response<auth.UserCredential>> signInAnonymously() {
    return authDelegate.signInAnonymously();
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    return authDelegate.signInWithApple();
  }

  @override
  Future<Response<bool>> signInWithBiometric({BiometricConfig? config}) {
    return authDelegate.signInWithBiometric(config: config);
  }

  @override
  Future<Response<auth.UserCredential>> signInWithCredential({
    required auth.AuthCredential credential,
  }) {
    return authDelegate.signInWithCredential(credential: credential);
  }

  @override
  Future<Response<auth.UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return authDelegate.signInWithEmailNPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    return authDelegate.signInWithFacebook();
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() {
    return authDelegate.signInWithGameCenter();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    return authDelegate.signInWithGithub();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    return authDelegate.signInWithGoogle();
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() {
    return authDelegate.signInWithMicrosoft();
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() {
    return authDelegate.signInWithPlayGames();
  }

  @override
  Future<Response<Credential>> signInWithSAML() {
    return authDelegate.signInWithSAML();
  }

  @override
  Future<Response<Credential>> signInWithTwitter() {
    return authDelegate.signInWithTwitter();
  }

  @override
  Future<Response<auth.UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return authDelegate.signInWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<Credential>> signInWithYahoo() {
    return authDelegate.signInWithYahoo();
  }

  @override
  Future<Response<Auth<AuthKeys>>> signOut([AuthProviders? provider]) {
    return authDelegate.signOut(provider);
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return authDelegate.signInWithEmailNPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Response<auth.UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return authDelegate.signUpWithUsernameNPassword(
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
    return authDelegate.verifyPhoneNumber(
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
