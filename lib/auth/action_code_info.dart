class IActionCodeInfo {
  final IActionCodeInfoData data;
  final IActionCodeInfoOperation operation;

  const IActionCodeInfo({
    required this.data,
    required this.operation,
  });
}

class IActionCodeInfoData {
  final String? email;
  final String? previousEmail;

  const IActionCodeInfoData({
    required this.email,
    required this.previousEmail,
  });
}

enum IActionCodeInfoOperation {
  unknown,
  passwordReset,
  verifyEmail,
  recoverEmail,
  emailSignIn,
  verifyAndChangeEmail,
  revertSecondFactorAddition,
}
