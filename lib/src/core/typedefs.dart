part of 'core.dart';

typedef OnAuthErrorListener = void Function(
  BuildContext context,
  String error,
);
typedef OnAuthMessageListener = void Function(
  BuildContext context,
  String message,
);
typedef OnAuthLoadingListener = void Function(
  BuildContext context,
  bool loading,
);
typedef OnAuthStateChangeListener = void Function(
  BuildContext context,
  AuthState state,
);
typedef OnAuthResponse<T extends Auth> = void Function(
  BuildContext context,
  AuthResponse<T> response,
);
typedef IdentityBuilder = String Function(String uid);
typedef SignByBiometricCallback = Future<bool> Function(bool biometric);
typedef SignOutCallback = Future Function(Auth authorizer);
typedef UndoAccountCallback = Future<bool> Function(Auth authorizer);
