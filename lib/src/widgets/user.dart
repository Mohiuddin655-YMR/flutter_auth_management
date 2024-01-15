import 'package:auth_management/core.dart';
import 'package:auth_management/src/utils/auth_notifier.dart';
import 'package:auth_management/src/utils/errors.dart';
import 'package:flutter/material.dart';

typedef OnAuthUserBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  T? value,
);

class AuthorizedUser<T extends Auth> extends StatelessWidget {
  final OnAuthUserBuilder<T> builder;

  const AuthorizedUser({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Support<T>(
        notifier: context.liveAuth<T>(),
        builder: builder,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthorizedUser<${AuthProvider.type}>();",
      );
    }
  }
}

class _Support<T extends Auth> extends StatefulWidget {
  final AuthNotifier<T> notifier;
  final OnAuthUserBuilder<T> builder;

  const _Support({
    super.key,
    required this.notifier,
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
    widget.notifier.addListener(_change);
  }

  @override
  void didUpdateWidget(_Support<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_change);
      widget.notifier.addListener(_change);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_change);
    super.dispose();
  }

  void _change() => setState(() => _data = widget.notifier.value);

  @override
  Widget build(BuildContext context) => widget.builder(context, _data);
}

class AuthUserControls<T extends Auth> {
  final AuthController<T> controller;

  const AuthUserControls._(this.controller);

  Future<T?> update(Map<String, dynamic> data) => controller.update(data);

  Future<AuthResponse<T>> delete() => controller.delete();

  Future<bool> addBiometric(
    bool enabled, {
    BiometricConfig? config,
  }) {
    return controller.addBiometric(enabled, config: config);
  }

  Future<bool> biometricEnable(bool enabled) {
    return controller.biometricEnable(enabled);
  }
}
