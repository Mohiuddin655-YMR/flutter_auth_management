import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../models/auth.dart';
import '../utils/auth_notifier.dart';
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
        notifier: context.liveUser<T>(),
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
  final T? initial;
  final AuthNotifier<T?> notifier;
  final OnAuthUserBuilder<T> builder;

  const _Support({
    super.key,
    this.initial,
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
    _data = widget.notifier.value;
    widget.notifier.addListener(_change);
  }

  @override
  void didUpdateWidget(_Support<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_change);
      widget.notifier.addListener(_change);
      _data = widget.notifier.value;
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_change);
    super.dispose();
  }

  void _change() => setState(() => _data = widget.notifier.value);

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data ?? widget.initial);
  }
}
