import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'twitter.com';

class TwitterAuthProvider extends IAuthProvider {
  TwitterAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential({
    required String accessToken,
    required String secret,
    String? providerId,
  }) {
    return TwitterAuthCredential._credential(
      accessToken: accessToken,
      secret: secret,
      providerId: providerId,
    );
  }

  static String get TWITTER_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  Map<String, String> _parameters = {};

  Map<String, String> get parameters {
    return _parameters;
  }

  TwitterAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class TwitterAuthCredential extends IOAuthCredential {
  const TwitterAuthCredential._({
    required String accessToken,
    required String secret,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
          secret: secret,
        );

  factory TwitterAuthCredential._credential({
    required String accessToken,
    required String secret,
    String? providerId,
  }) {
    return TwitterAuthCredential._(
      accessToken: accessToken,
      secret: secret,
      providerId: providerId,
    );
  }
}
