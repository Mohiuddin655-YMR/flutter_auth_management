part of 'delegate.dart';

/// Holds authentication data after sign in.
class IGoogleSignInTokenData {
  /// Build `GoogleSignInTokenData`.
  IGoogleSignInTokenData({
    required this.idToken,
    required this.accessToken,
    required this.serverAuthCode,
  });

  /// An OpenID Connect ID token for the authenticated user.
  String? idToken;

  /// The OAuth2 access token used to access Google services.
  String? accessToken;

  /// Server auth code used to access Google Login
  String? serverAuthCode;
}
