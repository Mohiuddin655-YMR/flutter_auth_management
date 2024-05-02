part of 'delegate.dart';

/// defines the login ui Behavior on Android
enum IFacebookLoginBehavior {
  nativeWithFallback,
  nativeOnly,
  katanaOnly,
  dialogOnly,
  deviceAuth,
  webOnly,
}
