import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth.dart';
import '../models/auth_state.dart';
import '../models/biometric_status.dart';
import '../utils/auth_response.dart';

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
typedef SignByBiometricCallback = Future<BiometricStatus?>? Function(
  BiometricStatus? status,
);
typedef SignOutCallback = Future Function(Auth authorizer);
typedef UndoAccountCallback = Future<bool> Function(Auth authorizer);
