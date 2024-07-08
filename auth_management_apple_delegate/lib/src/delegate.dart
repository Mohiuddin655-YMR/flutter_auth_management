import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthDelegate extends IAppleAuthDelegate {
  @override
  Future<IAppleAuthorizationCredentialAppleID> getAppleIDCredential({
    List<IAppleIDAuthorizationScopes> scopes = const [
      IAppleIDAuthorizationScopes.email,
      IAppleIDAuthorizationScopes.fullName,
    ],
    IAppleWebAuthenticationOptions? webAuthenticationOptions,
    String? nonce,
    String? state,
  }) async {
    return SignInWithApple.getAppleIDCredential(
      scopes: _scopes(scopes),
      webAuthenticationOptions: _options(webAuthenticationOptions),
      nonce: nonce,
      state: state,
    ).then((result) {
      return IAppleAuthorizationCredentialAppleID(
        userIdentifier: result.userIdentifier,
        givenName: result.givenName,
        familyName: result.familyName,
        authorizationCode: result.authorizationCode,
        email: result.email,
        identityToken: result.identityToken,
        state: result.state,
      );
    });
  }

  @override
  Future<IAppleCredentialState> getCredentialState(String userIdentifier) {
    return SignInWithApple.getCredentialState(userIdentifier).then((value) {
      if (value == CredentialState.authorized) {
        return IAppleCredentialState.authorized;
      } else if (value == CredentialState.revoked) {
        return IAppleCredentialState.revoked;
      } else {
        return IAppleCredentialState.notFound;
      }
    });
  }

  @override
  Future<IAppleAuthorizationCredentialPassword> getKeychainCredential() {
    return SignInWithApple.getKeychainCredential().then((value) {
      return IAppleAuthorizationCredentialPassword(
        username: value.username,
        password: value.password,
      );
    });
  }

  @override
  Future<bool> isAvailable() => SignInWithApple.isAvailable();

  List<AppleIDAuthorizationScopes> _scopes(
    List<IAppleIDAuthorizationScopes> scopes,
  ) {
    return scopes.map(_scope).toList();
  }

  AppleIDAuthorizationScopes _scope(IAppleIDAuthorizationScopes scope) {
    switch (scope) {
      case IAppleIDAuthorizationScopes.email:
        return AppleIDAuthorizationScopes.email;
      case IAppleIDAuthorizationScopes.fullName:
        return AppleIDAuthorizationScopes.fullName;
    }
  }

  WebAuthenticationOptions? _options(
    IAppleWebAuthenticationOptions? options,
  ) {
    if (options != null) {
      return WebAuthenticationOptions(
        clientId: options.clientId,
        redirectUri: options.redirectUri,
      );
    } else {
      return null;
    }
  }
}
