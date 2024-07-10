import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_entity/flutter_entity.dart';

import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../repositories/auth_repository.dart';

abstract class AuthHandler {
  final AuthRepository repository;

  const AuthHandler(this.repository);

  User? get user;

  Future<Response> get delete;

  Future<bool> isSignIn([AuthProviders? provider]);

  Future<Response<Auth>> signOut([AuthProviders? provider]);

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

  Future<Response<UserCredential>> signInWithCredential({
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

  Future<Response<void>> signInByPhone({
    String? phoneNumber,
    int? forceResendingToken,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(PhoneAuthCredential credential) onComplete,
    required void Function(FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  });
}
