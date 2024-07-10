import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'gc.apple.com';

class GameCenterAuthProvider extends IAuthProvider {
  GameCenterAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential([String? providerId]) {
    return GameCenterAuthCredential._credential(providerId);
  }

  static String get GAME_CENTER_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  Map<String, String> _parameters = {};

  Map<String, String> get parameters {
    return _parameters;
  }

  GameCenterAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class GameCenterAuthCredential extends IOAuthCredential {
  const GameCenterAuthCredential._([String? providerId])
      : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
        );

  factory GameCenterAuthCredential._credential([String? providerId]) {
    return GameCenterAuthCredential._(providerId);
  }
}
