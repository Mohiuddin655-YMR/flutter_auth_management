import 'package:auth_management/auth_management.dart';
import 'package:auth_management_apple_delegate/auth_management_apple_delegate.dart';
import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
import 'package:auth_management_facebook_delegate/auth_management_facebook_delegate.dart';
import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';

OAuthDelegates get oauthDelegates {
  return OAuthDelegates(
    appleAuthDelegate: AppleAuthDelegate(),
    biometricAuthDelegate: BiometricAuthDelegate(),
    facebookAuthDelegate: FacebookAuthDelegate(),
    googleAuthDelegate: GoogleAuthDelegate(),
  );
}
