part 'android_messages.dart';
part 'ios_messages.dart';
part 'messages.dart';
part 'options.dart';
part 'type.dart';
part 'window_messages.dart';

/// A Flutter plugin for authenticating the user identity locally.
abstract class IBiometricAuthDelegate {
  /// Authenticates the user with biometrics available on the device while also
  /// allowing the user to use device authentication - pin, pattern, passcode.
  ///
  /// Returns true if the user successfully authenticated, false otherwise.
  ///
  /// [localizedReason] is the message to show to user while prompting them
  /// for authentication. This is typically along the lines of: 'Authenticate
  /// to access MyApp.'. This must not be empty.
  ///
  /// Provide [authMessages] if you want to
  /// customize messages in the dialogs.
  ///
  /// Provide [options] for configuring further authentication related options.
  ///
  /// Throws a [PlatformException] if there were technical problems with local
  /// authentication (e.g. lack of relevant hardware). This might throw
  /// [PlatformException] with error code [otherOperatingSystem] on the iOS
  /// simulator.
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<IBiometricMessages> authMessages = const <IBiometricMessages>[
      IOSBiometricMessages(),
      AndroidBiometricMessages(),
      WindowsBiometricMessages()
    ],
    IBiometricOptions options = const IBiometricOptions(),
  });

  /// Cancels any in-progress authentication, returning true if auth was
  /// cancelled successfully.
  ///
  /// This API is not supported by all platforms.
  /// Returns false if there was some error, no authentication in progress,
  /// or the current platform lacks support.
  Future<bool> stopAuthentication();

  /// Returns true if device is capable of checking biometrics.
  Future<bool> get canCheckBiometrics;

  /// Returns true if device is capable of checking biometrics or is able to
  /// fail over to device credentials.
  Future<bool> isDeviceSupported();

  /// Returns a list of enrolled biometrics.
  Future<List<IBiometricType>> getAvailableBiometrics();
}
