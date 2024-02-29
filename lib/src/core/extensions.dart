import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_andomie/core.dart';

import '../models/auth.dart';
import '../models/auth_providers.dart';
import '../models/auth_state.dart';
import '../models/biometric_config.dart';
import '../services/controllers/controller.dart';
import '../utils/auth_notifier.dart';
import '../utils/auth_response.dart';
import '../utils/authenticator_email.dart';
import '../utils/authenticator_oauth.dart';
import '../utils/authenticator_otp.dart';
import '../utils/authenticator_phone.dart';
import '../utils/authenticator_username.dart';
import '../utils/errors.dart';
import '../widgets/provider.dart';
import 'typedefs.dart';

extension AuthContextExtension on BuildContext {
  AuthController<T> _i<T extends Auth>(String name) {
    try {
      return findAuthController<T>();
    } catch (_) {
      throw AuthProviderException(
        "You should call like $name<${AuthProvider.type}>()",
      );
    }
  }

  AuthProvider<T>? findAuthProvider<T extends Auth>() {
    try {
      return AuthProvider.of<T>(this);
    } catch (_) {
      throw AuthProviderException(
        "You should call like findAuthProvider<${AuthProvider.type}>()",
      );
    }
  }

  AuthController<T> findAuthController<T extends Auth>() {
    try {
      return AuthProvider.controllerOf<T>(this);
    } catch (_) {
      throw AuthProviderException(
        "You should call like findAuthController<${AuthProvider.type}>()",
      );
    }
  }

  Future<T?> auth<T extends Auth>() => _i<T>("auth").auth;

  AuthNotifier<String> liveError<T extends Auth>() {
    return _i<T>("liveError").liveError;
  }

  AuthNotifier<bool> liveLoading<T extends Auth>() {
    return _i<T>("liveLoading").liveLoading;
  }

  AuthNotifier<String> liveMessage<T extends Auth>() {
    return _i<T>("liveMessage").liveMessage;
  }

  AuthNotifier<T?> liveUser<T extends Auth>() {
    return _i<T>("liveAuth").liveUser;
  }

  AuthNotifier<AuthState> liveState<T extends Auth>() {
    return _i<T>("liveState").liveState;
  }

  Future<bool> isBiometricEnabled<T extends Auth>() {
    return _i<T>("isBiometricEnabled").isBiometricEnabled;
  }

  Future<bool> isLoggedIn<T extends Auth>() {
    return _i<T>("isLoggedIn").isLoggedIn;
  }

  Future<AuthResponse<T>> emit<T extends Auth>(AuthResponse<T> data) {
    return _i<T>("emit").emit(data);
  }

  Future<T?> updateAccount<T extends Auth>(Map<String, dynamic> data) {
    return _i<T>("updateAccount").update(null, data, updateMode: true);
  }

  Future<AuthResponse<T>> deleteAccount<T extends Auth>() {
    return _i<T>("deleteAccount").delete();
  }

  Future<Response<bool>> addBiometric<T extends Auth>({
    required SignByBiometricCallback callback,
    BiometricConfig? config,
  }) {
    return _i<T>("addBiometric").addBiometric(
      callback: callback,
      config: config,
    );
  }

  Future<Response<bool>> biometricEnable<T extends Auth>(bool enabled) {
    return _i<T>("biometricEnable").biometricEnable(enabled);
  }

  Future<AuthResponse<T>> isSignIn<T extends Auth>([
    AuthProviders? provider,
  ]) {
    return _i<T>("isSignIn").isSignIn(provider);
  }

  Future<AuthResponse<T>> signInByApple<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    return _i<T>("signInByApple").signInByApple(
      authenticator: authenticator,
      storeToken: storeToken,
    );
  }

  Future<AuthResponse<T>> signInByBiometric<T extends Auth>({
    BiometricConfig? config,
  }) {
    return _i<T>("signInByBiometric").signInByBiometric(config: config);
  }

  Future<AuthResponse<T>> signInByEmail<T extends Auth>(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    return _i<T>("signInByEmail").signInByEmail(
      authenticator,
      onBiometric: onBiometric,
    );
  }

  Future<AuthResponse<T>> signInByFacebook<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    return _i<T>("signInByFacebook").signInByFacebook(
      authenticator: authenticator,
      storeToken: storeToken,
    );
  }

  Future<AuthResponse<T>> signInByGithub<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    return _i<T>("signInByGithub").signInByGithub(
      authenticator: authenticator,
      storeToken: storeToken,
    );
  }

  Future<AuthResponse<T>> signInByGoogle<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    return _i<T>("signInByGoogle").signInByGoogle(
      authenticator: authenticator,
      storeToken: storeToken,
    );
  }

  Future<AuthResponse<T>> signInByPhone<T extends Auth>(
    PhoneAuthenticator authenticator, {
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(PhoneAuthCredential credential)? onComplete,
    void Function(FirebaseAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
  }) {
    return _i<T>("signInByPhone").signInByPhone(
      authenticator,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  Future<AuthResponse<T>> signInByOtp<T extends Auth>(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
  }) {
    return _i<T>("signInByOtp").signInByOtp(
      authenticator,
      storeToken: storeToken,
    );
  }

  Future<AuthResponse<T>> signInByUsername<T extends Auth>(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    return _i<T>("signInByUsername").signInByUsername(
      authenticator,
      onBiometric: onBiometric,
    );
  }

  Future<AuthResponse<T>> signUpByEmail<T extends Auth>(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    return _i<T>("signUpByEmail").signUpByEmail(
      authenticator,
      onBiometric: onBiometric,
    );
  }

  Future<AuthResponse<T>> signUpByUsername<T extends Auth>(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    return _i<T>("signUpByUsername").signUpByUsername(
      authenticator,
      onBiometric: onBiometric,
    );
  }

  Future<AuthResponse<T>> signOut<T extends Auth>([
    AuthProviders provider = AuthProviders.none,
  ]) {
    return _i<T>("signOut").signOut(provider);
  }

  Future<AuthResponse> verifyPhoneByOtp<T extends Auth>(
    OtpAuthenticator authenticator,
  ) {
    return _i<T>("verifyPhoneByOtp").verifyPhoneByOtp(authenticator);
  }
}

extension AuthFutureExtension<T extends Auth> on Future<AuthResponse<T>> {
  Future<AuthResponse<T>> onStatus(void Function(bool loading) callback) async {
    callback(true);
    final data = await this;
    callback(false);
    return data;
  }
}
