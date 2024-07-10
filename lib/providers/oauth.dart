import '../auth/auth_credential.dart';
import '../auth/auth_provider.dart';
import 'apple_auth.dart';

class IOAuthProvider extends IAuthProvider {
  IOAuthProvider(super.providerId);

  List<String> _scopes = [];
  Map<String, String> _parameters = {};

  List<String> get scopes {
    return _scopes;
  }

  Map<String, String> get parameters {
    return _parameters;
  }

  IOAuthProvider setScopes(List<String> scopes) {
    _scopes = scopes;
    return this;
  }

  IOAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  IOAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }

  IOAuthCredential credential({
    String? accessToken,
    String? secret,
    String? idToken,
    String? rawNonce,
    String? signInMethod,
  }) {
    return IOAuthCredential(
      providerId: providerId,
      signInMethod: signInMethod ?? 'oauth',
      accessToken: accessToken,
      secret: secret,
      idToken: idToken,
      rawNonce: rawNonce,
    );
  }
}

class IOAuthCredential extends IAuthCredential {
  final String? idToken;
  final String? secret;
  final String? rawNonce;
  final String? serverAuthCode;
  final IAppleFullPersonName? appleFullPersonName;

  const IOAuthCredential({
    required super.providerId,
    required super.signInMethod,
    super.accessToken,
    this.idToken,
    this.secret,
    this.rawNonce,
    this.serverAuthCode,
    this.appleFullPersonName,
  });
}
