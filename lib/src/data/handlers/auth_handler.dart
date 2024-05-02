import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_entity/flutter_entity.dart';

import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/handlers/auth_handler.dart';
import '../../services/sources/auth_data_source.dart';
import '../repositories/auth_repository.dart';

class AuthHandlerImpl extends AuthHandler {
  AuthHandlerImpl(AuthDataSource source)
      : super(AuthRepositoryImpl(source: source));

  const AuthHandlerImpl.fromRepository(super.repository);

  @override
  User? get user => repository.user;

  @override
  Future<Response> get delete {
    return repository.delete.onError((_, __) => Response(exception: "$_"));
  }

  @override
  Future<bool> isSignIn([AuthProviders? provider]) {
    try {
      return repository.isSignIn(provider).onError((_, __) => false);
    } catch (_) {
      return Future.value(false);
    }
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    try {
      return repository.signInWithApple().onError((_, __) {
        return Response<Credential>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<Credential>(exception: "$_"));
    }
  }

  @override
  Future<Response<bool>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    try {
      return repository.signInWithBiometric(config: config).onError((_, __) {
        return Response<bool>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<bool>(exception: "$_"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) async {
    try {
      return repository
          .signInWithCredential(credential: credential)
          .onError((_, __) => Response<UserCredential>(exception: "$_"));
    } catch (_) {
      return Future.value(Response<UserCredential>(exception: "$_"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository
          .signInWithEmailNPassword(email: email, password: password)
          .onError((_, __) => Response<UserCredential>(exception: "$_"));
    } catch (_) {
      return Future.value(Response<UserCredential>(exception: "$_"));
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    try {
      return repository.signInWithFacebook().onError((_, __) {
        return Response<Credential>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<Credential>(exception: "$_"));
    }
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    try {
      return repository.signInWithGithub().onError((_, __) {
        return Response<Credential>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<Credential>(exception: "$_"));
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    try {
      return repository.signInWithGoogle().onError((_, __) {
        return Response<Credential>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<Credential>(exception: "$_"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository
          .signInWithUsernameNPassword(username: username, password: password)
          .onError((_, __) => Response<UserCredential>(exception: "$_"));
    } catch (_) {
      return Future.value(Response<UserCredential>(exception: "$_"));
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository
          .signUpWithEmailNPassword(email: email, password: password)
          .onError((_, __) => Response<UserCredential>(exception: "$_"));
    } catch (_) {
      return Future.value(Response<UserCredential>(exception: "$_"));
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository
          .signUpWithUsernameNPassword(username: username, password: password)
          .onError((_, __) => Response<UserCredential>(exception: "$_"));
    } catch (_) {
      return Future.value(Response<UserCredential>(exception: "$_"));
    }
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) {
    try {
      return repository.signOut(provider).onError((_, __) {
        return Response<Auth>(exception: "$_");
      });
    } catch (_) {
      return Future.value(Response<Auth>(exception: "$_"));
    }
  }

  @override
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
  }) {
    try {
      return repository
          .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            forceResendingToken: forceResendingToken,
            multiFactorInfo: multiFactorInfo,
            multiFactorSession: multiFactorSession,
            timeout: timeout,
            onComplete: onComplete,
            onFailed: onFailed,
            onCodeSent: onCodeSent,
            onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
          )
          .onError((_, __) => Response(exception: "$_"));
    } catch (_) {
      return Future.value(Response(exception: "$_"));
    }
  }
}
