import 'package:flutter/material.dart';

import '../core/core.dart';
import '../models/models.dart';
import '../services/controllers/controllers.dart';

typedef OnAuthInfoBuilder<T extends Auth> = Widget Function(
    BuildContext context, AuthController<T>? controller, T? value);

typedef OnAuthInfoUpdate<T extends Auth> = Future<Map<String, dynamic>>
    Function(BuildContext context, T? value);

typedef OnAuthInfoError = Future<bool> Function(
    BuildContext context, String error);

class AuthorizedInfo<T extends Auth> extends StatefulWidget {
  final AuthController<T>? controller;
  final bool alwaysActive;
  final OnAuthInfoBuilder<T> builder;
  final OnAuthInfoUpdate<T>? onUpdate;
  final OnAuthInfoError? onError;

  const AuthorizedInfo({
    super.key,
    this.controller,
    this.alwaysActive = true,
    required this.builder,
    this.onUpdate,
    this.onError,
  });

  @override
  State<AuthorizedInfo<T>> createState() => _AuthorizedInfoState<T>();
}

class _AuthorizedInfoState<T extends Auth> extends State<AuthorizedInfo<T>> {
  @override
  Widget build(BuildContext context) {
    final con = widget.controller ?? AuthProvider.controllerOf<T>(context);
    if (widget.alwaysActive) {
      return StreamBuilder(
        stream: con.liveAuth,
        builder: (context, value) {
          final data = value.data;
          final child = widget.builder(context, con, data);
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
          final child = widget.builder(context, con, data);
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
      widget.onUpdate?.call(context, data).then((value) {
        if (!widget.alwaysActive) setState(() {});
        controller.update(value).then((value) {
          if (!widget.alwaysActive) setState(() {});
        });
      });
    } else if (widget.onError != null) {
      widget.onError?.call(context, "Authorization not found!");
    }
  }
}
