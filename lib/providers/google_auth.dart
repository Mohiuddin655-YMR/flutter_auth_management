import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'google.com';

class GoogleAuthProvider extends IAuthProvider {
  GoogleAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential({
    String? idToken,
    String? accessToken,
    String? providerId,
  }) {
    assert(accessToken != null || idToken != null,
        'At least one of ID token and access token is required');
    return GoogleAuthCredential._credential(
      idToken: idToken,
      accessToken: accessToken,
      providerId: providerId,
    );
  }

  static String get GOOGLE_SIGN_IN_METHOD {
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

  GoogleAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  GoogleAuthProvider setCustomParameters(
    Map<dynamic, dynamic> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class GoogleAuthCredential extends IOAuthCredential {
  const GoogleAuthCredential._({
    String? accessToken,
    String? idToken,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
          idToken: idToken,
        );

  factory GoogleAuthCredential._credential({
    String? idToken,
    String? accessToken,
    String? providerId,
  }) {
    return GoogleAuthCredential._(
      accessToken: accessToken,
      idToken: idToken,
      providerId: providerId,
    );
  }
}
