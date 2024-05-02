part of 'delegate.dart';

/// Android side authentication messages.
///
/// Provides default values for all messages.

class AndroidBiometricMessages extends IBiometricMessages {
  /// Constructs a new instance.
  const AndroidBiometricMessages({
    this.biometricHint,
    this.biometricNotRecognized,
    this.biometricRequiredTitle,
    this.biometricSuccess,
    this.cancelButton,
    this.deviceCredentialsRequiredTitle,
    this.deviceCredentialsSetupDescription,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.signInTitle,
  });

  /// Hint message advising the user how to authenticate with biometrics.
  /// Maximum 60 characters.
  final String? biometricHint;

  /// Message to let the user know that authentication was failed.
  /// Maximum 60 characters.
  final String? biometricNotRecognized;

  /// Message shown as a title in a dialog which indicates the user
  /// has not set up biometric authentication on their device.
  /// Maximum 60 characters.
  final String? biometricRequiredTitle;

  /// Message to let the user know that authentication was successful.
  /// Maximum 60 characters
  final String? biometricSuccess;

  /// Message shown on a button that the user can click to leave the
  /// current dialog.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// Message shown as a title in a dialog which indicates the user
  /// has not set up credentials authentication on their device.
  /// Maximum 60 characters.
  final String? deviceCredentialsRequiredTitle;

  /// Message advising the user to go to the settings and configure
  /// device credentials on their device.
  final String? deviceCredentialsSetupDescription;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog.
  /// Maximum 30 characters.
  final String? goToSettingsButton;

  /// Message advising the user to go to the settings and configure
  /// biometric on their device.
  final String? goToSettingsDescription;

  /// Message shown as a title in a dialog which indicates the user
  /// that they need to scan biometric to continue.
  /// Maximum 60 characters.
  final String? signInTitle;
}
