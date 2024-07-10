import 'dart:async';

import 'package:flutter_entity/flutter_entity.dart';

import '../../../auth/authorizer.dart';
import '../../../auth/exception.dart';
import '../../../auth/multi_factor.dart';
import '../../../providers/phone_auth.dart';
import '../../core/messages.dart';
import '../../core/typedefs.dart';
import '../../data/controllers/controller.dart';
import '../../delegates/backup.dart';
import '../../delegates/oauth.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/auth_state.dart';
import '../../models/biometric_config.dart';
import '../../utils/auth_notifier.dart';
import '../../utils/auth_response.dart';
import '../../utils/authenticator_email.dart';
import '../../utils/authenticator_oauth.dart';
import '../../utils/authenticator_otp.dart';
import '../../utils/authenticator_phone.dart';
import '../../utils/authenticator_username.dart';

abstract class AuthController<T extends Auth> {
  static AuthController? _i;

  static AuthController<T> getInstance<T extends Auth>({
    required Authorizer authorizer,
    OAuthDelegates? oauth,
    BackupDelegate<T>? backup,
    AuthMessages? messages,
  }) {
    if (_i is AuthController<T>) {
      return _i as AuthController<T>;
    } else {
      _i = AuthControllerImpl<T>(
        authorizer: authorizer,
        delegates: oauth,
        backup: backup,
        messages: messages,
      );
      return _i as AuthController<T>;
    }
  }

  Future<T?> get auth {
    throw UnimplementedError('auth is not implemented');
  }

  String get error {
    throw UnimplementedError('error is not implemented');
  }

  bool get loading {
    throw UnimplementedError('loading is not implemented');
  }

  String get message {
    throw UnimplementedError('message is not implemented');
  }

  AuthState get state {
    throw UnimplementedError('state is not implemented');
  }

  T? get user {
    throw UnimplementedError('user is not implemented');
  }

  AuthNotifier<String> get liveError {
    throw UnimplementedError('liveError is not implemented');
  }

  AuthNotifier<bool> get liveLoading {
    throw UnimplementedError('liveLoading is not implemented');
  }

  AuthNotifier<String> get liveMessage {
    throw UnimplementedError('liveMessage is not implemented');
  }

  AuthNotifier<AuthState> get liveState {
    throw UnimplementedError('liveState is not implemented');
  }

  AuthNotifier<T?> get liveUser {
    throw UnimplementedError('liveUser is not implemented');
  }

  Future<T?> initialize([bool initialCheck = true]) {
    throw UnimplementedError('initialize is not implemented');
  }

  void dispose() {
    throw UnimplementedError('dispose is not implemented');
  }

  Future<bool> get isBiometricEnabled {
    throw UnimplementedError('isBiometricEnabled is not implemented');
  }

  Future<bool> get isLoggedIn {
    throw UnimplementedError('isLoggedIn is not implemented');
  }

  Future<AuthResponse<T>> emit(AuthResponse<T> data) {
    throw UnimplementedError('emit() is not implemented');
  }

  Future<T?> update(Map<String, dynamic> data) {
    throw UnimplementedError('update() is not implemented');
  }

  Future<AuthResponse<T>> delete() {
    throw UnimplementedError('delete() is not implemented');
  }

  Future<Response<bool>> addBiometric({
    required SignByBiometricCallback callback,
    BiometricConfig? config,
  }) {
    throw UnimplementedError('addBiometric() is not implemented');
  }

  Future<Response<bool>> biometricEnable(bool enabled) {
    throw UnimplementedError('biometricEnable() is not implemented');
  }

  Future<AuthResponse<T>> isSignIn([
    AuthProviders? provider,
  ]) {
    throw UnimplementedError('isSignIn() is not implemented');
  }

  Future<AuthResponse<T>> signInByApple({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    throw UnimplementedError('signInByApple() is not implemented');
  }

  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
  }) {
    throw UnimplementedError('signInByBiometric() is not implemented');
  }

  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    throw UnimplementedError('signInByEmail() is not implemented');
  }

  Future<AuthResponse<T>> signInByFacebook({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    throw UnimplementedError('signInByFacebook() is not implemented');
  }

  Future<AuthResponse<T>> signInByGithub({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    throw UnimplementedError('signInByGithub() is not implemented');
  }

  Future<AuthResponse<T>> signInByGoogle({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
  }) {
    throw UnimplementedError('signInByGoogle() is not implemented');
  }

  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    IPhoneMultiFactorInfo? multiFactorInfo,
    IMultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(IPhoneAuthCredential credential)? onComplete,
    void Function(IAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
  }) {
    throw UnimplementedError('signInByPhone() is not implemented');
  }

  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
  }) {
    throw UnimplementedError('signInByOtp() is not implemented');
  }

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    throw UnimplementedError('signInByUsername() is not implemented');
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    throw UnimplementedError('signUpByEmail() is not implemented');
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
  }) {
    throw UnimplementedError('signUpByUsername() is not implemented');
  }

  Future<AuthResponse<T>> signOut([
    AuthProviders provider = AuthProviders.none,
  ]) {
    throw UnimplementedError('signOut() is not implemented');
  }

  Future<AuthResponse> verifyPhoneByOtp(OtpAuthenticator authenticator) {
    throw UnimplementedError('verifyPhoneByOtp() is not implemented');
  }
}
