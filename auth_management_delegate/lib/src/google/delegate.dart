part 'account.dart';
part 'authentication.dart';
part 'token_data.dart';
part 'user_data.dart';

abstract class IGoogleAuthDelegate {
  /// Subscribe to this stream to be notified when the current user changes.
  Stream<IGoogleSignInAccount?> get onCurrentUserChanged;

  /// The currently signed in account, or null if the user is signed out.
  IGoogleSignInAccount? get currentUser;

  /// Attempts to sign in a previously authenticated user without interaction.
  ///
  /// Returned Future resolves to an instance of [GoogleSignInAccount] for a
  /// successful sign in or `null` if there is no previously authenticated user.
  /// Use [signIn] method to trigger interactive sign in process.
  ///
  /// Authentication is triggered if there is no currently signed in
  /// user (that is when `currentUser == null`), otherwise this method returns
  /// a Future which resolves to the same user instance.
  ///
  /// Re-authentication can be triggered after [signOut] or [disconnect]. It can
  /// also be triggered by setting [reAuthenticate] to `true` if a new ID token
  /// is required.
  ///
  /// When [suppressErrors] is set to `false` and an error occurred during sign in
  /// returned Future completes with [PlatformException] whose `code` can be
  /// one of [kSignInRequiredError] (when there is no authenticated user) ,
  /// [kNetworkError] (when a network error occurred) or [kSignInFailedError]
  /// (when an unknown error occurred).
  Future<IGoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  });

  /// Returns a future that resolves to whether a user is currently signed in.
  Future<bool> isSignedIn();

  /// Starts the interactive sign-in process.
  ///
  /// Returned Future resolves to an instance of [GoogleSignInAccount] for a
  /// successful sign in or `null` in case sign in process was aborted.
  ///
  /// Authentication process is triggered only if there is no currently signed in
  /// user (that is when `currentUser == null`), otherwise this method returns
  /// a Future which resolves to the same user instance.
  ///
  /// Re-authentication can be triggered only after [signOut] or [disconnect].
  Future<IGoogleSignInAccount?> signIn();

  /// Marks current user as being in the signed out state.
  Future<IGoogleSignInAccount?> signOut();

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<IGoogleSignInAccount?> disconnect();

  /// Requests the user grants additional Oauth [scopes].
  Future<bool> requestScopes(List<String> scopes);

  /// Checks if the current user has granted access to all the specified [scopes].
  ///
  /// Optionally, an [accessToken] can be passed to perform this check. This
  /// may be useful when an application holds on to a cached, potentially
  /// long-lived [accessToken].
  Future<bool> canAccessScopes(
    List<String> scopes, {
    String? accessToken,
  });
}
