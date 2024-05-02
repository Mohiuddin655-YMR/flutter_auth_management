part of 'delegate.dart';

/// Abstract class for storing platform specific strings.
abstract class IBiometricMessages {
  /// Constructs an instance of [IBiometricMessages].
  const IBiometricMessages();

  factory IBiometricMessages.android({
    String? goToSettingsButton,
    String? goToSettingsDescription,
    String? cancelButton,
    String? biometricHint,
    String? biometricNotRecognized,
    String? biometricRequiredTitle,
    String? biometricSuccess,
    String? deviceCredentialsRequiredTitle,
    String? deviceCredentialsSetupDescription,
    String? signInTitle,
  }) {
    return AndroidBiometricMessages(
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      cancelButton: cancelButton,
      biometricHint: biometricHint,
      biometricNotRecognized: biometricNotRecognized,
      biometricRequiredTitle: biometricRequiredTitle,
      biometricSuccess: biometricSuccess,
      deviceCredentialsRequiredTitle: deviceCredentialsRequiredTitle,
      deviceCredentialsSetupDescription: deviceCredentialsSetupDescription,
      signInTitle: signInTitle,
    );
  }

  factory IBiometricMessages.ios({
    String? goToSettingsButton,
    String? goToSettingsDescription,
    String? cancelButton,
    String? lockOut,
    String? localizedFallbackTitle,
  }) {
    return IOSBiometricMessages(
      lockOut: lockOut,
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      cancelButton: cancelButton,
      localizedFallbackTitle: localizedFallbackTitle,
    );
  }

  factory IBiometricMessages.windows() {
    return const WindowsBiometricMessages();
  }
}
