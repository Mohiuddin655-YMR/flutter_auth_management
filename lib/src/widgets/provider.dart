import 'package:auth_management/src/utils/errors.dart';
import 'package:flutter/material.dart';

import '../models/auth.dart';
import '../services/controllers/controller.dart';
import '../utils/auth_response.dart';

class AuthProvider<T extends Auth> extends InheritedWidget {
  final AuthController<T> controller;

  AuthProvider({
    super.key,
    required this.controller,
    required Widget child,
  }) : super(child: _Support<T>(controller: controller, child: child)) {
    type = T;
  }

  static Type? type;

  static AuthProvider<T> of<T extends Auth>(BuildContext context) {
    final x = context.dependOnInheritedWidgetOfExactType<AuthProvider<T>>();
    if (x != null) {
      return x;
    } else {
      throw AuthProviderException(
        "You should call like of<${AuthProvider.type}>();",
      );
    }
  }

  static AuthController<T> controllerOf<T extends Auth>(BuildContext context) {
    try {
      return of<T>(context).controller;
    } catch (_) {
      throw AuthProviderException(
        "You should call like of<${AuthProvider.type}>();",
      );
    }
  }

  @override
  bool updateShouldNotify(covariant AuthProvider<T> oldWidget) {
    return controller != oldWidget.controller;
  }

  void notify(AuthResponse<T> value) => controller.emit(value);
}

class _Support<T extends Auth> extends StatefulWidget {
  final AuthController<T> controller;
  final Widget child;

  const _Support({
    required this.child,
    required this.controller,
  });

  @override
  State<_Support<T>> createState() => _SupportState<T>();
}

class _SupportState<T extends Auth> extends State<_Support<T>> {
  @override
  void initState() {
    widget.controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
