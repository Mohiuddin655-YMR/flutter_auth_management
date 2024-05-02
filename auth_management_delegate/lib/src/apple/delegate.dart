part 'credential.dart';
part 'password.dart';
part 'state.dart';

abstract class IAppleAuthDelegate {
  Future<bool> isAvailable();

  Future<AppleCredentialState> getCredentialState(String id);

  Future<AppleAuthorizationCredentialPassword> getKeychainCredential();

  Future<AppleAuthorizationCredentialAppleID> getAppleIDCredential();
}
