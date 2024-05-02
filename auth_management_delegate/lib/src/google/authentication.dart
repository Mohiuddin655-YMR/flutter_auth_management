part of 'delegate.dart';

class IGoogleSignInAuthentication {
  IGoogleSignInAuthentication(this._data);

  final IGoogleSignInTokenData _data;

  /// An OpenID Connect ID token that identifies the user.
  String? get idToken => _data.idToken;

  /// The OAuth2 access token to access Google services.
  String? get accessToken => _data.accessToken;

  /// Server auth code used to access Google Login
  @Deprecated('Use the `GoogleSignInAccount.serverAuthCode` property instead')
  String? get serverAuthCode => _data.serverAuthCode;

  @override
  String toString() => 'GoogleSignInAuthentication:$_data';
}
