part of 'delegate.dart';

/// The scopes that will be requested with the [AppleIDAuthorizationRequest].
/// This allows you to request additional information from the user upon sign up.
///
/// This information will only be provided on the first authorizations.
/// Upon further authorizations, you will only get the user identifier,
/// meaning you will need to store this data securely on your servers.
/// For more information see: https://forums.developer.apple.com/thread/121496
///
/// Apple Docs: https://developer.apple.com/documentation/authenticationservices/asauthorization/scope
enum IAppleIDAuthorizationScopes {
  email,
  fullName,
}
