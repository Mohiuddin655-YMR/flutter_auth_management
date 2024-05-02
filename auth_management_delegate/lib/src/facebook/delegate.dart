part 'behavior.dart';
part 'permissions.dart';
part 'result.dart';
part 'token.dart';

abstract class IFacebookAuthDelegate {
  /// if the user is logged return one instance of AccessToken
  Future<IFacebookAccessToken?> get accessToken;

  /// Express login logs people in with their Facebook account across devices and platform.
  /// If a person logs into your app on Android and then changes devices,
  /// express login logs them in with their Facebook account, instead of asking for them to select a login method.
  ///
  /// This avoid creating duplicate accounts or failing to log in at all. To support the changes in Android 11,
  /// first add the following code to the queries element in your /app/manifest/AndroidManifest.xml file.
  /// For more info go to https://developers.facebook.com/docs/facebook-login/android
  Future<IFacebookLoginResult> expressLogin();

  /// retrive the user information using the GraphAPI
  ///
  /// [fields] string of fields like birthday,email,hometown
  ///
  /// The facebook SDK will return a JSON like
  /// ```
  /// {
  ///  "name": "Open Graph Test User",
  ///  "email": "open_jygexjs_user@tfbnw.net",
  ///  "picture": {
  ///    "data": {
  ///      "height": 126,
  ///      "url": "https://scontent.fuio21-1.fna.fbcdn.net/v/t1.30497-1/s200x200/8462.jpg",
  ///      "width": 200
  ///    }
  ///  },
  ///  "id": "136742241592917"
  ///}
  ///```
  ///
  ///The above JSON could be change, it depends of your [fields] argument.
  Future<Map<String, dynamic>> getUserData({
    String fields = "name,email,picture.width(200)",
  });

  /// Sign Out from Facebook
  Future<void> logOut();

  /// make a login request using the facebook SDK
  ///
  /// [permissions] permissions like ["email","public_profile"]
  ///
  /// [loginBehavior] (only Android) use this param to set the UI for the authentication,
  /// like webview, native app, or a dialog.
  Future<IFacebookLoginResult> login({
    List<String> permissions = const ['email', 'public_profile'],
    IFacebookLoginBehavior loginBehavior =
        IFacebookLoginBehavior.nativeWithFallback,
  });

  /// call this method (ONLY FOR WEB) to initialize the facebook javascript sdk
  Future<void> webAndDesktopInitialize({
    required String appId,
    required bool cookie,
    required bool xfbml,
    required String version,
  });

  /// returns one instance of FacebookPermission with the granted and declined permissions
  ///
  /// It could be null if you exceed the request limit
  Future<IFacebookPermissions?> get permissions;

  /// use this to know if the facebook sdk was initializated on Web
  /// on Android and iOS is always true
  bool get isWebSdkInitialized;

  /// ONLY FOR iOS: enable or disable AutoLogAppEvents
  Future<void> autoLogAppEventsEnabled(bool enabled);

  /// ONLY FOR iOS: check if AutoLogAppEvents are enabled

  Future<bool> get isAutoLogAppEventsEnabled;
}
