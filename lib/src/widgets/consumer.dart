import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../models/auth.dart';
import '../services/controllers/controller.dart';
import '../utils/errors.dart';
import 'provider.dart';

typedef OnAuthUserBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  T? value,
);

class AuthConsumer<T extends Auth> extends StatelessWidget {
  final T? initial;
  final OnAuthUserBuilder<T> builder;

  const AuthConsumer({
    super.key,
    this.initial,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Support<T>(
        controller: context.findAuthController<T>(),
        initial: initial,
        builder: builder,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthConsumer<${AuthProvider.type}>();",
      );
    }
  }
}

class _Support<T extends Auth> extends StatefulWidget {
  final T? initial;
  final AuthController<T> controller;
  final OnAuthUserBuilder<T> builder;

  const _Support({
    super.key,
    this.initial,
    required this.controller,
    required this.builder,
  });

  @override
  State<_Support<T>> createState() => _SupportState<T>();
}

class _SupportState<T extends Auth> extends State<_Support<T>> {
  T? _data;

  @override
  void initState() {
    super.initState();
    widget.controller.auth.then(_change);
    widget.controller.liveUser.addListener(_change);
  }

  @override
  void didUpdateWidget(_Support<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.liveUser.removeListener(_change);
      widget.controller.liveUser.addListener(_change);
      widget.controller.auth.then(_change);
    }
  }

  @override
  void dispose() {
    widget.controller.liveUser.removeListener(_change);
    super.dispose();
  }

  void _change([T? data]) {
    setState(() => _data = data ?? widget.controller.liveUser.value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data ?? widget.initial);
  }
}
