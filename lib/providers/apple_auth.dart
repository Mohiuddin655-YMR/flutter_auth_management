import '../auth/auth_provider.dart';
import 'oauth.dart';

const _kProviderId = 'apple.com';

class AppleAuthProvider extends IAuthProvider {
  AppleAuthProvider([
    String? providerId,
  ]) : super(providerId ?? _kProviderId);

  static IOAuthCredential credential(
    String accessToken, {
    String? providerId,
  }) {
    return AppleAuthCredential._credential(
      accessToken,
      providerId: providerId,
    );
  }

  static IOAuthCredential credentialWithIDToken(
    String idToken,
    String rawNonce,
    IAppleFullPersonName appleFullPersonName, {
    String? providerId,
  }) {
    return AppleAuthCredential._credentialWithIDToken(
      idToken,
      rawNonce,
      appleFullPersonName,
      providerId: providerId,
    );
  }

  static String get APPLE_SIGN_IN_METHOD {
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

  AppleAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  AppleAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

class AppleAuthCredential extends IOAuthCredential {
  const AppleAuthCredential._({
    super.accessToken,
    super.rawNonce,
    super.idToken,
    super.appleFullPersonName,
    String? providerId,
  }) : super(
          providerId: providerId ?? _kProviderId,
          signInMethod: providerId ?? _kProviderId,
        );

  factory AppleAuthCredential._credential(
    String accessToken, {
    String? providerId,
  }) {
    return AppleAuthCredential._(
      accessToken: accessToken,
      providerId: providerId,
    );
  }

  factory AppleAuthCredential._credentialWithIDToken(
    String idToken,
    String rawNonce,
    IAppleFullPersonName appleFullPersonName, {
    String? providerId,
  }) {
    return AppleAuthCredential._(
      idToken: idToken,
      rawNonce: rawNonce,
      appleFullPersonName: appleFullPersonName,
      providerId: providerId,
    );
  }
}

class IAppleFullPersonName {
  const IAppleFullPersonName({
    this.givenName,
    this.familyName,
    this.middleName,
    this.nickname,
    this.namePrefix,
    this.nameSuffix,
  });

  final String? givenName;
  final String? familyName;
  final String? middleName;
  final String? nickname;
  final String? namePrefix;
  final String? nameSuffix;
}
