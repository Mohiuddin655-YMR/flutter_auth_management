import 'authenticator.dart';

class GuestAuthenticator extends Authenticator {
  GuestAuthenticator({
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super.guest();
}
