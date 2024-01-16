import 'authenticator.dart';
import 'authenticator_otp.dart';

class PhoneAuthenticator extends Authenticator {
  PhoneAuthenticator({
    required super.phone,
    String? token,
    super.id,
    super.timeMills,
    super.email,
    super.idToken,
    super.name,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super.phone(accessToken: token);

  OtpAuthenticator otp({
    required String token,
    required String smsCode,
  }) {
    return OtpAuthenticator(
      token: token,
      smsCode: smsCode,
      email: email,
      extra: extra,
      id: id,
      name: name,
      phone: phone,
      photo: photo,
      provider: provider,
      timeMills: timeMills,
      username: username,
    );
  }

  @override
  String get phone => super.phone ?? "";
}
