import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

class BiometricConfig {
  final String deviceException;
  final String failureException;
  final String checkingException;
  final String localizedReason;
  final AuthenticationOptions options;

  // Android
  final String? biometricHint;
  final String? biometricNotRecognized;
  final String? biometricRequiredTitle;
  final String? biometricSuccess;
  final String? deviceCredentialsRequiredTitle;
  final String? deviceCredentialsSetupDescription;
  final String? signInTitle;

  AndroidAuthMessages get androidAuthMessages {
    return AndroidAuthMessages(
      biometricHint: biometricHint,
      biometricNotRecognized: biometricNotRecognized,
      biometricRequiredTitle: biometricRequiredTitle,
      biometricSuccess: biometricSuccess,
      cancelButton: cancelButton,
      deviceCredentialsRequiredTitle: deviceCredentialsRequiredTitle,
      deviceCredentialsSetupDescription: deviceCredentialsSetupDescription,
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      signInTitle: signInTitle,
    );
  }

  // IOS
  final String? lockOut;
  final String? goToSettingsButton;
  final String? goToSettingsDescription;
  final String? cancelButton;
  final String? localizedFallbackTitle;

  IOSAuthMessages get iosAuthMessages {
    return IOSAuthMessages(
      lockOut: lockOut,
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      cancelButton: cancelButton,
      localizedFallbackTitle: localizedFallbackTitle,
    );
  }

  // Widow
  WindowsAuthMessages get windowsAuthMessages {
    return const WindowsAuthMessages();
  }

  List<AuthMessages> get authMessages {
    return [
      androidAuthMessages,
      iosAuthMessages,
      windowsAuthMessages,
    ];
  }

  const BiometricConfig({
    // Ios
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
    this.localizedFallbackTitle,
    // Android
    this.biometricHint,
    this.biometricNotRecognized,
    this.biometricRequiredTitle,
    this.biometricSuccess,
    this.deviceCredentialsRequiredTitle,
    this.deviceCredentialsSetupDescription,
    this.signInTitle,
    // Base
    this.deviceException = "Device isn't supported!",
    this.failureException = "Biometric matching failed!",
    this.checkingException = "Can not check biometrics!",
    this.localizedReason =
        "Scan your fingerprint (or face or whatever) to authenticate",
    this.options = const AuthenticationOptions(
      stickyAuth: true,
      biometricOnly: true,
    ),
  });
}
