import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthDelegate extends IAppleAuthDelegate {
  @override
  Future<bool> isAvailable() => SignInWithApple.isAvailable();

  @override
  Future<AppleCredentialState> getCredentialState(String id) {
    return SignInWithApple.getCredentialState(id).then((value) {
      if (value == CredentialState.authorized) {
        return AppleCredentialState.authorized;
      } else if (value == CredentialState.revoked) {
        return AppleCredentialState.revoked;
      } else {
        return AppleCredentialState.notFound;
      }
    });
  }

  @override
  Future<AppleAuthorizationCredentialPassword> getKeychainCredential() {
    return SignInWithApple.getKeychainCredential().then((value) {
      return AppleAuthorizationCredentialPassword(
        username: value.username,
        password: value.password,
      );
    });
  }

  @override
  Future<AppleAuthorizationCredentialAppleID> getAppleIDCredential() async {
    return SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    ).then((result) {
      return AppleAuthorizationCredentialAppleID(
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
}
