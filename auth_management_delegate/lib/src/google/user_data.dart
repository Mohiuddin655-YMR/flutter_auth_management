part of 'delegate.dart';

/// Holds information about the signed in user.
class IGoogleSignInUserData {
  /// Uses the given data to construct an instance.
  const IGoogleSignInUserData({
    required this.email,
    required this.id,
    this.displayName,
    this.photoUrl,
    this.serverAuthCode,
  });

  /// The display name of the signed in user.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  final String? displayName;

  /// The email address of the signed in user.
  ///
  /// Applications should not key users by email address since a Google account's
  /// email address can change. Use [id] as a key instead.
  ///
  /// _Important_: Do not use this returned email address to communicate the
  /// currently signed in user to your backend server. Instead, send an ID token
  /// which can be securely validated on the server. See [idToken].
  final String email;

  /// The unique ID for the Google account.
  ///
  /// This is the preferred unique key to use for a user record.
  ///
  /// _Important_: Do not use this returned Google ID to communicate the
  /// currently signed in user to your backend server. Instead, send an ID token
  /// which can be securely validated on the server. See [idToken].
  final String id;

  /// The photo url of the signed in user if the user has a profile picture.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  final String? photoUrl;

  /// Server auth code used to access Google Login
  final String? serverAuthCode;
}
