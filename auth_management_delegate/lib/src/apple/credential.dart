part of 'delegate.dart';

class IAppleAuthorizationCredentialAppleID {
  /// Creates an instance which contains the result of a successful Sign in with Apple flow.
  const IAppleAuthorizationCredentialAppleID({
    required this.userIdentifier,
    required this.givenName,
    required this.familyName,
    required this.authorizationCode,
    required this.email,
    required this.identityToken,
    required this.state,
  });

  /// An identifier associated with the authenticated user.
  ///
  /// This will always be provided on iOS and macOS systems. On Android, however, this will not be present.
  /// This will stay the same between sign ins, until the user deauthorizes your App.
  final String? userIdentifier;

  /// The users given name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? givenName;

  /// The users family name, in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.fullName] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? familyName;

  /// The users email in case it was requested.
  /// You will need to provide the [AppleIDAuthorizationScopes.email] scope to the [AppleIDAuthorizationRequest] for requesting this information.
  ///
  /// This information will only be provided on the first authorizations.
  /// Upon further authorizations, you will only get the [userIdentifier],
  /// meaning you will need to store this data securely on your servers.
  /// For more information see: https://forums.developer.apple.com/thread/121496
  final String? email;

  /// The verification code for the current authorization.
  ///
  /// This code should be used by your server component to validate the authorization with Apple within 5 minutes upon receiving it.
  final String authorizationCode;

  /// A JSON Web Token (JWT) that securely communicates information about the user to your app.
  final String? identityToken;

  /// The `state` parameter that was passed to the request.
  ///
  /// This data is not modified by Apple.
  final String? state;

  @override
  String toString() {
    return 'AuthorizationCredentialAppleID($userIdentifier, $givenName, $familyName, $email, [identityToken set: ${identityToken != null}], $state)';
  }
}
