import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'playgames.google.com';

class PlayGamesAuthProvider extends IAuthProvider {
  PlayGamesAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential({
    required String serverAuthCode,
    String? providerId,
  }) {
    return PlayGamesAuthCredential._credential(
      serverAuthCode: serverAuthCode,
      providerId: providerId,
    );
  }

  static String get PLAY_GAMES_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  Map<String, String> _parameters = {};

  Map<String, String> get parameters {
    return _parameters;
  }

  PlayGamesAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class PlayGamesAuthCredential extends IOAuthCredential {
  const PlayGamesAuthCredential._({
    required String serverAuthCode,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          serverAuthCode: serverAuthCode,
        );

  factory PlayGamesAuthCredential._credential({
    required String serverAuthCode,
    String? providerId,
  }) {
    return PlayGamesAuthCredential._(
      serverAuthCode: serverAuthCode,
      providerId: providerId,
    );
  }
}
