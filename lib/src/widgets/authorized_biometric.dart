import 'dart:async';

import 'package:flutter/material.dart';

import '../core/core.dart';
import '../models/models.dart';
import '../services/controllers/controllers.dart';

typedef OnAuthBiometricBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  AuthController<T>? controller,
  BiometricState state,
);

typedef OnAuthBiometricUpdate = Future<bool> Function(
  BuildContext context,
  bool value,
);

typedef OnAuthBiometricError = Future<bool> Function(
  BuildContext context,
  String error,
);

enum BiometricState {
  checking,
  enabled,
  disabled;

  bool get isChecking => this == checking;

  bool get isEnabled => this == enabled;

  bool get isDisabled => this == disabled;

  factory BiometricState.check(Auth? data, bool isLoading) {
    if (data != null) {
      return data.isBiometric
          ? BiometricState.enabled
          : BiometricState.disabled;
    } else {
      return isLoading ? BiometricState.checking : BiometricState.disabled;
    }
  }
}

class AuthorizedBiometric<T extends Auth> extends StatefulWidget {
  final AuthController<T>? controller;
  final bool alwaysActive;
  final OnAuthBiometricBuilder<T> builder;
  final OnAuthBiometricUpdate? onUpdate;
  final OnAuthBiometricError? onError;

  const AuthorizedBiometric({
    super.key,
    this.controller,
    this.alwaysActive = true,
    required this.builder,
    this.onUpdate,
    this.onError,
  });

  @override
  State<AuthorizedBiometric<T>> createState() => _AuthorizedBiometricState<T>();
}

class _AuthorizedBiometricState<T extends Auth>
    extends State<AuthorizedBiometric<T>> {
  late AuthController<T> _controller;

  late StreamSubscription<T?> _subscription;

  BiometricState state = BiometricState.disabled;

  @override
  void initState() {
    _controller = widget.controller ?? AuthProvider.controllerOf<T>(context);
    // _subscription = _controller.liveAuth.listen(_change);
    super.initState();
  }

  @override
  void dispose() {
    // _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final con = widget.controller ?? AuthProvider.controllerOf<T>(context);
    if (widget.alwaysActive) {
      return StreamBuilder(
        stream: con.liveAuth,
        builder: (context, value) {
          final data = value.data;
          final state = BiometricState.check(
            data,
            value.connectionState == ConnectionState.waiting,
          );
          final child = widget.builder(context, con, state);
          if (data != null && widget.onUpdate != null) {
            return GestureDetector(
              onTap: () => _update(con, data),
              child: child,
            );
          }
          return child;
        },
      );
    } else {
      return FutureBuilder(
        future: con.auth,
        builder: (context, value) {
          final data = value.data;
          final state = BiometricState.check(
            data,
            value.connectionState == ConnectionState.waiting,
          );
          final child = widget.builder(context, con, state);
          if (data != null && widget.onUpdate != null) {
            return GestureDetector(
              onTap: () => _update(con, data),
              child: child,
            );
          }
          return child;
        },
      );
    }
  }

  void _update(AuthController<T> controller, T? data) {
    if (data != null) {
      widget.onUpdate?.call(context, data.isBiometric).then((value) {
        if (!widget.alwaysActive) setState(() {});
        controller.addBiometric(value).then((value) {
          if (!widget.alwaysActive && !value) setState(() {});
        });
      });
    } else if (widget.onError != null) {
      widget.onError?.call(context, "Authorization not found!");
    }
  }
}
