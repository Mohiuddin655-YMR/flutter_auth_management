import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'yahoo.com';

class YahooAuthProvider extends IAuthProvider {
  YahooAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential(
    String accessToken, {
    String? providerId,
  }) {
    return YahooAuthCredential._credential(
      accessToken,
      providerId: providerId,
    );
  }

  static String get YAHOO_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  final List<String> _scopes = [];
  Map<dynamic, dynamic> _parameters = {};

  List<String> get scopes {
    return _scopes;
  }

  Map<dynamic, dynamic> get parameters {
    return _parameters;
  }

  YahooAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  YahooAuthProvider setCustomParameters(
    Map<dynamic, dynamic> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class YahooAuthCredential extends IOAuthCredential {
  const YahooAuthCredential._({
    required String accessToken,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
        );

  factory YahooAuthCredential._credential(
    String accessToken, {
    String? providerId,
  }) {
    return YahooAuthCredential._(
      accessToken: accessToken,
      providerId: providerId,
    );
  }
}
