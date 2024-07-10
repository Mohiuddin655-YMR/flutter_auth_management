import '../../auth/auth_credential.dart';
import '../../providers/phone_auth.dart';
import 'authenticator.dart';

enum OtpType {
  phone;

  bool get isPhone => this == phone;
}

class OtpAuthenticator extends Authenticator {
  final OtpType type;

  OtpAuthenticator({
    required String token,
    required String smsCode,
    this.type = OtpType.phone,
    super.email,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super.otp(idToken: token, accessToken: smsCode);

  String get token => super.idToken ?? "";

  String get smsCode => super.accessToken ?? "";

  IAuthCredential get credential {
    return PhoneAuthProvider.credential(
      verificationId: token,
      smsCode: smsCode,
    );
  }
}
