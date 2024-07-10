import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'microsoft.com';

class MicrosoftAuthProvider extends IAuthProvider {
  MicrosoftAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential(String accessToken) {
    return MicrosoftAuthCredential._credential(
      accessToken,
    );
  }

  static String get MICROSOFT_SIGN_IN_METHOD {
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

  MicrosoftAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  MicrosoftAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class MicrosoftAuthCredential extends IOAuthCredential {
  const MicrosoftAuthCredential._({
    required String accessToken,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
          accessToken: accessToken,
        );

  factory MicrosoftAuthCredential._credential(
    String accessToken, {
    String? providerId,
  }) {
    return MicrosoftAuthCredential._(
      accessToken: accessToken,
      providerId: providerId,
    );
  }
}
