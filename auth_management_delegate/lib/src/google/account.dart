part of 'delegate.dart';

/// Holds fields describing a signed in user's identity, following
/// [GoogleSignInUserData].
///
/// [id] is guaranteed to be non-null.
class IGoogleSignInAccount {
  IGoogleSignInAccount? currentUser;
  Future<IGoogleSignInTokenData> Function({
    required String email,
    bool? shouldRecoverAuth,
  }) getTokens;

  Future<void> Function({required String token}) onClearAuthCache;

  IGoogleSignInAccount(
    IGoogleSignInUserData data, {
    this.currentUser,
    required this.getTokens,
    required this.onClearAuthCache,
    required this.authentication,
    required this.authHeaders,
  })  : displayName = data.displayName,
        email = data.email,
        id = data.id,
        photoUrl = data.photoUrl,
        serverAuthCode = data.serverAuthCode;

  final String? displayName;

  final String email;

  final String id;

  final String? photoUrl;

  final String? serverAuthCode;

  /// Retrieve [IGoogleSignInAuthentication] for this account.
  ///
  /// [shouldRecoverAuth] sets whether to attempt to recover authentication if
  /// user action is needed. If an attempt to recover authentication fails a
  /// [PlatformException] is thrown with possible error code
  /// [kFailedToRecoverAuthError].
  ///
  /// Otherwise, if [shouldRecoverAuth] is false and the authentication can be
  /// recovered by user action a [PlatformException] is thrown with error code
  /// [kUserRecoverableAuthError].
  Future<IGoogleSignInAuthentication> authentication;

  /// Convenience method returning a `<String, String>` map of HTML Authorization
  /// headers, containing the current `authentication.accessToken`.
  ///
  /// See also https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization.
  Future<Map<String, String>> authHeaders;

  /// Clears any client side cache that might be holding invalid tokens.
  ///
  /// If client runs into 401 errors using a token, it is expected to call
  /// this method and grab `authHeaders` once again.
  Future<void> clearAuthCache() async {
    final String token = (await authentication).accessToken!;
    await onClearAuthCache(token: token);
  }

  @override
  String toString() {
    final Map<String, dynamic> data = <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'id': id,
      'photoUrl': photoUrl,
      'serverAuthCode': serverAuthCode
    };
    return 'GoogleSignInAccount:$data';
  }
}
