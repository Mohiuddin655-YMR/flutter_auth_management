import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'facebook.com';

class FacebookAuthProvider extends IAuthProvider {
  FacebookAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential(
    String accessToken, {
    String? providerId,
  }) {
    return FacebookAuthCredential._credential(
      accessToken,
      providerId: providerId,
    );
  }

  static String get FACEBOOK_SIGN_IN_METHOD {
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

  FacebookAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  FacebookAuthProvider setCustomParameters(
    Map<dynamic, dynamic> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class FacebookAuthCredential extends IOAuthCredential {
  const FacebookAuthCredential._({
    required String accessToken,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
        );

  factory FacebookAuthCredential._credential(
    String accessToken, {
    String? providerId,
  }) {
    return FacebookAuthCredential._(
      accessToken: accessToken,
      providerId: providerId,
    );
  }
}
