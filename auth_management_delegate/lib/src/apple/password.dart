part of 'delegate.dart';

class IAppleAuthorizationCredentialPassword {
  /// Creates a new username/password combination, which is the result of a successful Keychain query.
  const IAppleAuthorizationCredentialPassword({
    required this.username,
    required this.password,
  });

  /// The username for the credential
  final String username;

  /// The password for the credential
  final String password;

  @override
  String toString() {
    return 'AppleAuthorizationCredentialPassword($username, [REDACTED password])';
  }
}
