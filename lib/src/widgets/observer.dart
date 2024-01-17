import 'package:auth_management/core.dart';
import 'package:auth_management/src/utils/errors.dart';
import 'package:flutter/material.dart';

class AuthObserver<T extends Auth> extends StatelessWidget {
  final bool liveAsBackground;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStatus;
  final Widget child;

  const AuthObserver({
    super.key,
    this.liveAsBackground = false,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStatus,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Observer<T>(
        controller: context.findAuthController<T>(),
        liveAsBackground: liveAsBackground,
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onState: onStatus,
        child: child,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthObserver<${AuthProvider.type}>()",
      );
    }
  }
}

class _Observer<T extends Auth> extends StatefulWidget {
  final bool liveAsBackground;
  final AuthController<T> controller;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onState;
  final Widget child;

  const _Observer({
    required this.controller,
    required this.liveAsBackground,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onState,
    required this.child,
  });

  @override
  State<_Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T extends Auth> extends State<_Observer<T>>
    with WidgetsBindingObserver {
  bool _isActiveMode = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _addListeners(widget.controller);
    super.initState();
  }

  @override
  void didUpdateWidget(_Observer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _removeListeners(oldWidget.controller);
      _addListeners(widget.controller);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _isActiveMode = false;
        break;
      case AppLifecycleState.resumed:
        _isActiveMode = true;
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeListeners(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _addListeners(AuthController<T> controller) {
    if (widget.onError != null) {
      controller.liveError.addListener(_changeError);
    }
    if (widget.onLoading != null) {
      controller.liveLoading.addListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      controller.liveMessage.addListener(_changeMessage);
    }
    if (widget.onState != null) {
      controller.liveState.addListener(_changeState);
    }
  }

  void _removeListeners(AuthController<T> controller) {
    if (widget.onError != null) {
      controller.liveError.removeListener(_changeError);
    }
    if (widget.onLoading != null) {
      controller.liveLoading.removeListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      controller.liveMessage.removeListener(_changeMessage);
    }
    if (widget.onState != null) {
      controller.liveState.removeListener(_changeState);
    }
  }

  bool get isLiveMode => _isActiveMode || widget.liveAsBackground;

  void _changeError() {
    if (widget.onError != null && isLiveMode) {
      final value = widget.controller.error;
      if (value.isNotEmpty) {
        widget.onError?.call(context, value);
      }
    }
  }

  void _changeLoading() {
    if (widget.onLoading != null && isLiveMode) {
      final value = widget.controller.loading;
      widget.onLoading?.call(context, value);
    }
  }

  void _changeMessage() {
    if (widget.onMessage != null && isLiveMode) {
      final value = widget.controller.message;
      if (value.isNotEmpty) {
        widget.onMessage?.call(context, value);
      }
    }
  }

  void _changeState() {
    if (widget.onState != null && isLiveMode) {
      final value = widget.controller.state;
      widget.onState?.call(context, value);
    }
  }
}
