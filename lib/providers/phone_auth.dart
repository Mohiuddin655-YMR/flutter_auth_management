import '../auth/auth_credential.dart';
import '../auth/auth_provider.dart';

const _kProviderId = 'phone';

class PhoneAuthProvider extends IAuthProvider {
  const PhoneAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static String get PHONE_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  static IPhoneAuthCredential credential({
    required String verificationId,
    required String smsCode,
    String? providerId,
  }) {
    return IPhoneAuthCredential._credential(
      verificationId,
      smsCode,
      providerId: providerId,
    );
  }

  static IPhoneAuthCredential credentialFromToken(
    int token, {
    String? smsCode,
    String? providerId,
  }) {
    return IPhoneAuthCredential._credentialFromToken(
      token,
      smsCode: smsCode,
      providerId: providerId,
    );
  }
}

class IPhoneAuthCredential extends IAuthCredential {
  const IPhoneAuthCredential._({
    this.verificationId,
    this.smsCode,
    int? token,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          token: token,
        );

  factory IPhoneAuthCredential._credential(
    String verificationId,
    String smsCode, {
    String? providerId,
  }) {
    return IPhoneAuthCredential._(
      verificationId: verificationId,
      smsCode: smsCode,
      providerId: providerId,
    );
  }

  factory IPhoneAuthCredential._credentialFromToken(
    int token, {
    String? smsCode,
    String? providerId,
  }) {
    return IPhoneAuthCredential._(
      token: token,
      smsCode: smsCode,
      providerId: providerId,
    );
  }

  final String? verificationId;

  final String? smsCode;
}
