import 'package:auth_management_delegates/auth_management_delegates.dart';

class OAuthDelegates {
  final IAppleAuthDelegate? appleAuthDelegate;
  final IBiometricAuthDelegate? biometricAuthDelegate;
  final IFacebookAuthDelegate? facebookAuthDelegate;
  final IGoogleAuthDelegate? googleAuthDelegate;

  const OAuthDelegates({
    this.appleAuthDelegate,
    this.biometricAuthDelegate,
    this.facebookAuthDelegate,
    this.googleAuthDelegate,
  });
}
