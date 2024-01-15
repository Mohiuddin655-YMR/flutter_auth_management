import 'package:auth_management/core.dart';
import 'package:auth_management/src/utils/errors.dart';
import 'package:flutter/material.dart';

class AuthObserver<T extends Auth> extends StatelessWidget {
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStatus;
  final OnAuthResponse<T>? onResponse;
  final Widget child;

  const AuthObserver({
    super.key,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStatus,
    this.onResponse,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Observer<T>(
        controller: context.findAuthController<T>(),
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onStateChange: onStatus,
        onResponse: onResponse,
        child: child,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthObserver<${AuthProvider.type}>();",
      );
    }
  }
}

class _Observer<T extends Auth> extends StatefulWidget {
  final AuthController<T> controller;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStateChange;
  final OnAuthResponse<T>? onResponse;
  final Widget child;

  const _Observer({
    required this.controller,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStateChange,
    this.onResponse,
    required this.child,
  });

  @override
  State<_Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T extends Auth> extends State<_Observer<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_change);
  }

  @override
  void didUpdateWidget(_Observer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_change);
      widget.controller.addListener(_change);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_change);
    super.dispose();
  }

  void _change() {
    final data = widget.controller.value;
    if (data.isMessage && widget.onMessage != null) {
      widget.onMessage?.call(context, data.message);
    }
    if (data.isLoading && widget.onLoading != null) {
      widget.onLoading?.call(context, data.isLoading);
    } else if (data.isError && widget.onError != null) {
      widget.onError?.call(context, data.error);
    } else if (data.isState && widget.onStateChange != null) {
      widget.onStateChange?.call(context, data.state);
    } else if (widget.onResponse != null) {
      widget.onResponse?.call(context, data);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
