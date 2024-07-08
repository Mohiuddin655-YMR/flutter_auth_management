import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

class BiometricAuthDelegate extends IBiometricAuthDelegate {
  LocalAuthentication? _i;

  LocalAuthentication get i => _i ??= LocalAuthentication();

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<IBiometricMessages> authMessages = const <IBiometricMessages>[
      IOSBiometricMessages(),
      AndroidBiometricMessages(),
      WindowsBiometricMessages()
    ],
    IBiometricOptions options = const IBiometricOptions(),
  }) {
    return i.authenticate(
      localizedReason: localizedReason,
      authMessages: authMessages.map((e) {
        if (e is IOSBiometricMessages) {
          return IOSAuthMessages(
            lockOut: e.lockOut,
            goToSettingsButton: e.goToSettingsButton,
            goToSettingsDescription: e.goToSettingsDescription,
            cancelButton: e.cancelButton,
            localizedFallbackTitle: e.localizedFallbackTitle,
          );
        } else if (e is AndroidBiometricMessages) {
          return AndroidAuthMessages(
            biometricHint: e.biometricHint,
            biometricNotRecognized: e.biometricNotRecognized,
            biometricRequiredTitle: e.biometricRequiredTitle,
            biometricSuccess: e.biometricSuccess,
            cancelButton: e.cancelButton,
            deviceCredentialsRequiredTitle: e.deviceCredentialsRequiredTitle,
            deviceCredentialsSetupDescription:
                e.deviceCredentialsSetupDescription,
            goToSettingsButton: e.goToSettingsButton,
            goToSettingsDescription: e.goToSettingsDescription,
            signInTitle: e.signInTitle,
          );
        } else {
          return const WindowsAuthMessages();
        }
      }).toList(),
      options: AuthenticationOptions(
        useErrorDialogs: options.useErrorDialogs,
        stickyAuth: options.stickyAuth,
        sensitiveTransaction: options.sensitiveTransaction,
        biometricOnly: options.biometricOnly,
      ),
    );
  }

  @override
  Future<bool> get canCheckBiometrics => i.canCheckBiometrics;

  @override
  Future<List<IBiometricType>> getAvailableBiometrics() {
    return i.getAvailableBiometrics().then((value) {
      return value.map((e) {
        switch (e) {
          case BiometricType.face:
            return IBiometricType.face;
          case BiometricType.fingerprint:
            return IBiometricType.fingerprint;
          case BiometricType.iris:
            return IBiometricType.iris;
          case BiometricType.strong:
            return IBiometricType.strong;
          case BiometricType.weak:
            return IBiometricType.weak;
        }
      }).toList();
    });
  }

  @override
  Future<bool> isDeviceSupported() => i.isDeviceSupported();

  @override
  Future<bool> stopAuthentication() => i.stopAuthentication();
}
