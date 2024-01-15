import 'package:firebase_auth/firebase_auth.dart';

import 'authenticator.dart';

class PhoneAuthenticator extends Authenticator {
  final PhoneAuthCredential? credential;

  PhoneAuthenticator({
    required String verificationId,
    required String smsCode,
    required super.phone,
    super.email,
    super.id,
    super.timeMills,
    super.name,
    super.photo,
    super.provider,
    super.username,
  })  : credential = null,
        super.phone(idToken: verificationId, accessToken: smsCode);

  PhoneAuthenticator.fromCredential({
    required PhoneAuthCredential this.credential,
    required super.phone,
    super.email,
    super.id,
    super.timeMills,
    super.name,
    super.photo,
    super.provider,
    super.username,
  }) : super.phone(idToken: "", accessToken: "");

  @override
  String get phone => super.phone ?? "";

  String get smsCode => super.accessToken ?? "";

  String get verificationId => super.idToken ?? "";
}
