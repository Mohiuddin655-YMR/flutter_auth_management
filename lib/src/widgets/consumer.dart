import 'package:flutter/material.dart';

import '../core/typedefs.dart';
import '../models/auth.dart';
import '../models/auth_state.dart';
import 'observer.dart';

typedef AuthConsumerBuilder = Widget Function(
  BuildContext context,
  AuthState state,
);

/// to listen auth status anywhere with [AuthConsumer]
class AuthConsumer<T extends Auth> extends StatefulWidget {
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthResponse<T>? onResponse;
  final AuthConsumerBuilder builder;

  const AuthConsumer({
    super.key,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onResponse,
    required this.builder,
  });

  @override
  State<AuthConsumer<T>> createState() => _AuthConsumerState<T>();
}

class _AuthConsumerState<T extends Auth> extends State<AuthConsumer<T>> {
  AuthState state = AuthState.unauthenticated;

  void _onStatus(BuildContext context, AuthState state) {
    setState(() => this.state = state);
  }

  @override
  Widget build(context) {
    return AuthObserver(
      onError: widget.onError,
      onLoading: widget.onLoading,
      onMessage: widget.onMessage,
      onResponse: widget.onResponse,
      onStatus: _onStatus,
      child: widget.builder(context, state),
    );
  }
}
