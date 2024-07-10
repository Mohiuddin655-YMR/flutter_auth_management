import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'github.com';

class GithubAuthProvider extends IAuthProvider {
  GithubAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential(
    String accessToken, {
    String? providerId,
  }) {
    return GithubAuthCredential._credential(
      accessToken,
      providerId: providerId,
    );
  }

  static String get GITHUB_SIGN_IN_METHOD {
    return _kProviderId;
  }

  static String get PROVIDER_ID {
    return _kProviderId;
  }

  final List<String> _scopes = [];
  Map<String, String> _parameters = {};

  List<String> get scopes {
    return _scopes;
  }

  Map<String, String> get parameters {
    return _parameters;
  }

  GithubAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  GithubAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class GithubAuthCredential extends IOAuthCredential {
  const GithubAuthCredential._({
    required String accessToken,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
        );

  factory GithubAuthCredential._credential(
    String accessToken, {
    String? providerId,
  }) {
    return GithubAuthCredential._(
      accessToken: accessToken,
      providerId: providerId,
    );
  }
}
