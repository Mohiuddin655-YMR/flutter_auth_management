import 'dart:async';

import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class GoogleAuthDelegate extends IGoogleAuthDelegate {
  GoogleSignIn? _i;

  GoogleSignIn get i => _i ??= GoogleSignIn(scopes: ['email']);

  @override
  Future<bool> canAccessScopes(
    List<String> scopes, {
    String? accessToken,
  }) {
    return i.canAccessScopes(scopes, accessToken: accessToken);
  }

  @override
  IGoogleSignInAccount? get currentUser => _account(i.currentUser);

  @override
  Future<IGoogleSignInAccount?> disconnect() => i.disconnect().then(_account);

  @override
  Future<bool> isSignedIn() => i.isSignedIn();

  @override
  Stream<IGoogleSignInAccount?> get onCurrentUserChanged {
    final controller = StreamController<IGoogleSignInAccount?>();
    i.onCurrentUserChanged.listen((event) {
      controller.add(_account(event));
    });
    return controller.stream;
  }

  @override
  Future<bool> requestScopes(List<String> scopes) => i.requestScopes(scopes);

  @override
  Future<IGoogleSignInAccount?> signIn() => i.signIn().then(_account);

  @override
  Future<IGoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  }) {
    return i
        .signInSilently(
            suppressErrors: suppressErrors, reAuthenticate: reAuthenticate)
        .then(_account);
  }

  @override
  Future<IGoogleSignInAccount?> signOut() => i.signOut().then(_account);

  IGoogleSignInAccount? _account(GoogleSignInAccount? value) {
    if (value != null) {
      final data = IGoogleSignInUserData(
        email: value.email,
        id: value.id,
        displayName: value.displayName,
        photoUrl: value.photoUrl,
        serverAuthCode: value.serverAuthCode,
      );
      return IGoogleSignInAccount(
        data,
        currentUser: null,
        getTokens: _tokens,
        onClearAuthCache: GoogleSignInPlatform.instance.clearAuthCache,
      );
    } else {
      return null;
    }
  }

  Future<IGoogleSignInTokenData> _tokens({
    required String email,
    bool? shouldRecoverAuth,
  }) {
    return GoogleSignInPlatform.instance
        .getTokens(email: email, shouldRecoverAuth: shouldRecoverAuth)
        .then((value) {
      return IGoogleSignInTokenData(
        idToken: value.idToken,
        accessToken: value.accessToken,
        serverAuthCode: value.serverAuthCode,
      );
    });
  }
}
