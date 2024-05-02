part of 'delegate.dart';

class IBiometricOptions {
  /// Constructs a new instance.
  const IBiometricOptions({
    this.useErrorDialogs = true,
    this.stickyAuth = false,
    this.sensitiveTransaction = true,
    this.biometricOnly = false,
  });

  /// Whether the system will attempt to handle user-fixable issues encountered
  /// while authenticating. For instance, if a fingerprint reader exists on the
  /// device but there's no fingerprint registered, the plugin might attempt to
  /// take the user to settings to add one. Anything that is not user fixable,
  /// such as no biometric sensor on device, will still result in
  /// a [PlatformException].
  final bool useErrorDialogs;

  /// Used when the application goes into background for any reason while the
  /// authentication is in progress. Due to security reasons, the
  /// authentication has to be stopped at that time. If stickyAuth is set to
  /// true, authentication resumes when the app is resumed. If it is set to
  /// false (default), then as soon as app is paused a failure message is sent
  /// back to Dart and it is up to the client app to restart authentication or
  /// do something else.
  final bool stickyAuth;

  /// Whether platform specific precautions are enabled. For instance, on face
  /// unlock, Android opens a confirmation dialog after the face is recognized
  /// to make sure the user meant to unlock their device.
  final bool sensitiveTransaction;

  /// Prevent authentications from using non-biometric local authentication
  /// such as pin, passcode, or pattern.
  final bool biometricOnly;
}
