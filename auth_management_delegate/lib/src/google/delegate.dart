import 'package:flutter/foundation.dart';

part 'account.dart';
part 'authentication.dart';
part 'types.dart';

abstract class IGoogleAuthDelegate {
  /// Initializes global sign-in configuration settings.
  ///
  /// The [signInOption] determines the user experience. [SigninOption.games]
  /// is only supported on Android.
  ///
  /// The list of [scopes] are OAuth scope codes to request when signing in.
  /// These scope codes will determine the level of data access that is granted
  /// to your application by the user. The full list of available scopes can
  /// be found here:
  /// <https://developers.google.com/identity/protocols/googlescopes>
  ///
  /// The [hostedDomain] argument specifies a hosted domain restriction. By
  /// setting this, sign in will be restricted to accounts of the user in the
  /// specified domain. By default, the list of accounts will not be restricted.
  ///
  /// The [forceCodeForRefreshToken] is used on Android to ensure the authentication
  /// code can be exchanged for a refresh token after the first request.
  IGoogleAuthDelegate({
    this.signInOption = IGoogleSignInOption.standard,
    this.scopes = const <String>[],
    this.hostedDomain,
    this.clientId,
    this.serverClientId,
    this.forceCodeForRefreshToken = false,
  });

  /// Factory for creating default sign in user experience.
  IGoogleAuthDelegate.standard({
    List<String> scopes = const <String>[],
    String? hostedDomain,
  }) : this(scopes: scopes, hostedDomain: hostedDomain);

  /// Factory for creating sign in suitable for games. This option is only
  /// supported on Android.
  IGoogleAuthDelegate.games() : this(signInOption: IGoogleSignInOption.games);

  // These error codes must match with ones declared on Android and iOS sides.

  /// Error code indicating there is no signed in user and interactive sign in
  /// flow is required.
  static const String kSignInRequiredError = 'sign_in_required';

  /// Error code indicating that interactive sign in process was canceled by the
  /// user.
  static const String kSignInCanceledError = 'sign_in_canceled';

  /// Error code indicating network error. Retrying should resolve the problem.
  static const String kNetworkError = 'network_error';

  /// Error code indicating that attempt to sign in failed.
  static const String kSignInFailedError = 'sign_in_failed';

  /// Option to determine the sign in user experience. [SignInOption.games] is
  /// only supported on Android.
  final IGoogleSignInOption signInOption;

  /// The list of [scopes] are OAuth scope codes requested when signing in.
  final List<String> scopes;

  /// Domain to restrict sign-in to.
  final String? hostedDomain;

  /// Client ID being used to connect to google sign-in.
  ///
  /// This option is not supported on all platforms (e.g. Android). It is
  /// optional if file-based configuration is used.
  ///
  /// The value specified here has precedence over a value from a configuration
  /// file.
  final String? clientId;

  /// Client ID of the backend server to which the app needs to authenticate
  /// itself.
  ///
  /// Optional and not supported on all platforms (e.g. web). By default, it
  /// is initialized from a configuration file if available.
  ///
  /// The value specified here has precedence over a value from a configuration
  /// file.
  ///
  /// [GoogleSignInAuthentication.idToken] and
  /// [GoogleSignInAccount.serverAuthCode] will be specific to the backend
  /// server.
  final String? serverClientId;

  /// Force the authorization code to be valid for a refresh token every time. Only needed on Android.
  final bool forceCodeForRefreshToken;

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
