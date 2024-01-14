part of 'entities.dart';

class OAuthAuthenticator extends Authenticator {
  OAuthAuthenticator({
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
  }) : super.oauth();
}
