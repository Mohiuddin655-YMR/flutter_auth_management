part of 'delegate.dart';

/// Class wrapping all authentication messages needed on iOS.
/// Provides default values for all messages.
class IOSBiometricMessages extends IBiometricMessages {
  /// Constructs a new instance.
  const IOSBiometricMessages({
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
    this.localizedFallbackTitle,
  });

  /// Message advising the user to re-enable biometrics on their device.
  final String? lockOut;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog.
  /// Maximum 30 characters.
  final String? goToSettingsButton;

  /// Message advising the user to go to the settings and configure Biometrics
  /// for their device.
  final String? goToSettingsDescription;

  /// Message shown on a button that the user can click to leave the current
  /// dialog.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// The localized title for the fallback button in the dialog presented to
  /// the user during authentication.
  final String? localizedFallbackTitle;
}
