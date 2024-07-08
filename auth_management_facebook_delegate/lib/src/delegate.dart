import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthDelegate extends IFacebookAuthDelegate {
  FacebookAuth? _i;

  FacebookAuth get i => _i ??= FacebookAuth.i;

  @override
  Future<IFacebookAccessToken?> get accessToken => i.accessToken.then(_token);

  @override
  Future<void> autoLogAppEventsEnabled(bool enabled) {
    return i.autoLogAppEventsEnabled(enabled);
  }

  @override
  Future<IFacebookLoginResult> expressLogin() => i.expressLogin().then(_result);

  @override
  Future<Map<String, dynamic>> getUserData({
    String fields = "name,email,picture.width(200)",
  }) {
    return i.getUserData(fields: fields);
  }

  @override
  Future<bool> get isAutoLogAppEventsEnabled => i.isAutoLogAppEventsEnabled;

  @override
  bool get isWebSdkInitialized => i.isWebSdkInitialized;

  @override
  Future<void> logOut() => i.logOut();

  @override
  @override
  Future<IFacebookLoginResult> login({
    List<String> permissions = const ['email', 'public_profile'],
    IFacebookLoginBehavior loginBehavior =
        IFacebookLoginBehavior.nativeWithFallback,
    IFacebookLoginTracking loginTracking = IFacebookLoginTracking.limited,
    String? nonce,
  }) {
    return i
        .login(
          permissions: permissions,
          loginBehavior: _behavior(loginBehavior),
          loginTracking: _tracking(loginTracking),
          nonce: nonce,
        )
        .then(_result);
  }

  @override
  Future<void> webAndDesktopInitialize({
    required String appId,
    required bool cookie,
    required bool xfbml,
    required String version,
  }) {
    return i.webAndDesktopInitialize(
      appId: appId,
      cookie: cookie,
      xfbml: xfbml,
      version: version,
    );
  }

  LoginBehavior _behavior(IFacebookLoginBehavior value) {
    switch (value) {
      case IFacebookLoginBehavior.nativeWithFallback:
        return LoginBehavior.nativeWithFallback;
      case IFacebookLoginBehavior.nativeOnly:
        return LoginBehavior.nativeOnly;
      case IFacebookLoginBehavior.katanaOnly:
        return LoginBehavior.katanaOnly;
      case IFacebookLoginBehavior.dialogOnly:
        return LoginBehavior.dialogOnly;
      case IFacebookLoginBehavior.deviceAuth:
        return LoginBehavior.deviceAuth;
      case IFacebookLoginBehavior.webOnly:
        return LoginBehavior.webOnly;
    }
  }

  LoginTracking _tracking(IFacebookLoginTracking value) {
    switch (value) {
      case IFacebookLoginTracking.limited:
        return LoginTracking.limited;
      case IFacebookLoginTracking.enabled:
        return LoginTracking.enabled;
    }
  }

  IFacebookLoginResult _result(LoginResult value) {
    return IFacebookLoginResult(
      status: _status(value.status),
      message: value.message,
      accessToken: _token(value.accessToken),
    );
  }

  IFacebookLoginStatus _status(LoginStatus value) {
    switch (value) {
      case LoginStatus.success:
        return IFacebookLoginStatus.success;
      case LoginStatus.cancelled:
        return IFacebookLoginStatus.cancelled;
      case LoginStatus.failed:
        return IFacebookLoginStatus.failed;
      case LoginStatus.operationInProgress:
        return IFacebookLoginStatus.operationInProgress;
    }
  }

  IFacebookAccessToken? _token(AccessToken? value) {
    if (value is LimitedToken) {
      return IFacebookLimitedToken(
        userId: value.userId,
        userName: value.userName,
        userEmail: value.userEmail,
        nonce: value.nonce,
        tokenString: value.tokenString,
      );
    } else if (value is ClassicToken) {
      return IFacebookClassicToken(
        declinedPermissions: value.declinedPermissions,
        grantedPermissions: value.grantedPermissions,
        userId: value.userId,
        expires: value.expires,
        tokenString: value.tokenString,
        applicationId: value.applicationId,
      );
    } else {
      return null;
    }
  }
}
