import 'dart:async';

import 'package:flutter/material.dart';

import '../core/core.dart';
import '../models/models.dart';
import '../responses/responses.dart';
import '../services/controllers/controllers.dart';

typedef OnAuthActionBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  AuthController<T> controller,
  AuthActionState state,
);

enum AuthActionState {
  initial,
  failed,
  loading,
  successful;

  bool get isInitial => this == initial;

  bool get isFailed => this == failed;

  bool get isLoading => this == loading;

  bool get isSuccessful => this == successful;

  factory AuthActionState.from(AuthResponse response) {
    if (response.isLoading) {
      return AuthActionState.loading;
    } else if (response.isError) {
      return AuthActionState.failed;
    } else if (response.state.isSuccessful) {
      return AuthActionState.successful;
    } else {
      return AuthActionState.initial;
    }
  }
}

class AuthBuilder<T extends Auth> extends StatefulWidget {
  final AuthActions action;
  final AuthController<T>? controller;
  final OnAuthActionBuilder<T> builder;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener? onStateChange;
  final OnAuthResponse<T>? onResponse;

  const AuthBuilder({
    super.key,
    required this.action,
    this.controller,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStateChange,
    this.onResponse,
    required this.builder,
  });

  @override
  State<AuthBuilder<T>> createState() => _AuthBuilderState<T>();
}

class _AuthBuilderState<T extends Auth>
    extends State<AuthBuilder<T>> {
  late AuthController<T> _controller;

  late StreamSubscription<AuthResponse<T>> _subscription;

  AuthActionState state = AuthActionState.initial;

  @override
  void initState() {
    _controller = widget.controller ?? AuthProvider.controllerOf<T>(context);
    _subscription = _controller.liveResponse.listen(_change);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  bool isCurrentAction(AuthResponse<T>? response) {
    if (response != null) {
      return response.isCurrentAction(widget.action);
    } else {
      return false;
    }
  }

  void _change(AuthResponse<T>? data) {
    if (isCurrentAction(data) && data != null) {
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
      setState(() => state = AuthActionState.from(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller, state);
  }
}
