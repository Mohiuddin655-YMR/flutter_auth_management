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
  Future<IFacebookLoginResult> login({
    List<String> permissions = const ['email', 'public_profile'],
    IFacebookLoginBehavior loginBehavior =
        IFacebookLoginBehavior.nativeWithFallback,
  }) {
    return i
        .login(
          permissions: permissions,
          loginBehavior: _behavior(loginBehavior),
        )
        .then(_result);
  }

  @override
  Future<IFacebookPermissions?> get permissions {
    return i.permissions.then((value) {
      if (value != null) {
        return IFacebookPermissions(
          granted: value.granted,
          declined: value.declined,
        );
      } else {
        return null;
      }
    });
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
    if (value != null) {
      return IFacebookAccessToken(
        declinedPermissions: value.declinedPermissions,
        grantedPermissions: value.grantedPermissions,
        userId: value.userId,
        expires: value.expires,
        lastRefresh: value.lastRefresh,
        token: value.token,
        applicationId: value.applicationId,
        isExpired: value.isExpired,
        dataAccessExpirationTime: value.dataAccessExpirationTime,
        graphDomain: value.graphDomain,
      );
    } else {
      return null;
    }
  }
}
