import '../models/auth.dart';

class Authenticator extends Auth {
  Authenticator.empty() : super();

  Authenticator.email({
    required String email,
    required String password,
    super.id,
    super.timeMills,
    super.accessToken,
    super.idToken,
    super.name,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super(email: email, password: password);

  Authenticator.oauth({
    super.id,
    super.timeMills,
    super.accessToken,
    super.idToken,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super();

  Authenticator.phone({
    required String phone,
    required String idToken,
    required String accessToken,
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super(phone: phone, idToken: idToken, accessToken: accessToken);

  Authenticator.username({
    required String username,
    required String password,
    super.id,
    super.timeMills,
    super.accessToken,
    super.idToken,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.provider,
    super.extra,
  }) : super(username: username, password: password);
}
