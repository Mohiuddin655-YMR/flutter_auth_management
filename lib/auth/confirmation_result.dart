import 'user_credential.dart';

typedef IConfirmationResultConfirm = Future<IUserCredential> Function(
  String verificationCode,
);

class IConfirmationResult {
  /// FIELDS
  final String verificationId;

  /// CALLBACKS
  final IConfirmationResultConfirm confirm;

  const IConfirmationResult({
    required this.verificationId,
    required this.confirm,
  });
}
