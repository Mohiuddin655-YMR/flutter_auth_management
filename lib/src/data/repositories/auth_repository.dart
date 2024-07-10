import 'package:flutter_entity/flutter_entity.dart';

import '../../../auth/auth_credential.dart';
import '../../../auth/exception.dart';
import '../../../auth/multi_factor.dart';
import '../../../auth/user.dart';
import '../../../auth/user_credential.dart';
import '../../../providers/phone_auth.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/repositories/auth_repository.dart';
import '../../services/sources/auth_data_source.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource source;

  const AuthRepositoryImpl({
    required this.source,
  });

  @override
  IUser? get user => source.user;

  @override
  Future<Response> get delete => source.delete;

  @override
  Future<bool> isSignIn([AuthProviders? provider]) => source.isSignIn();

  @override
  Future<Response<Credential>> signInWithApple() => source.signInWithApple();

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    return source.signInWithBiometric(config: config);
  }

  @override
  Future<Response<IUserCredential>> signInWithCredential({
    required IAuthCredential credential,
  }) {
    return source.signInWithCredential(credential: credential);
  }

  @override
  Future<Response<IUserCredential>> signInWithEmailNPassword({
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
  Future<Response<IUserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signInWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<IUserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    return source.signUpWithEmailNPassword(email: email, password: password);
  }

  @override
  Future<Response<IUserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    return source.signUpWithUsernameNPassword(
      username: username,
      password: password,
    );
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) => source.signOut();

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
  }) {
    return source.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }
}
