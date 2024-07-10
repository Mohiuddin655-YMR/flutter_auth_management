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
import '../repositories/auth_repository.dart';

abstract class AuthHandler {
  final AuthRepository repository;

  const AuthHandler(this.repository);

  IUser? get user;

  Future<Response> get delete;

  Future<bool> isSignIn([AuthProviders? provider]);

  Future<Response<Auth>> signOut([AuthProviders? provider]);

  Future<Response<Credential>> signInWithApple();

  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  });

  Future<Response<IUserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<IUserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<IUserCredential>> signInWithCredential({
    required IAuthCredential credential,
  });

  Future<Response<IUserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<IUserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<void>> signInByPhone({
    String? phoneNumber,
    int? forceResendingToken,
    IPhoneMultiFactorInfo? multiFactorInfo,
    IMultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(IPhoneAuthCredential credential) onComplete,
    required void Function(IAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  });
}
