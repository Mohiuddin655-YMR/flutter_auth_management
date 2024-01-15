import 'package:flutter/material.dart';

import '../models/auth.dart';
import '../models/auth_state.dart';
import 'observer.dart';

typedef OnAuthBuilder = Widget Function(
  BuildContext context,
  AuthState state,
);

/// to listen auth status anywhere with [AuthBuilder]
class AuthBuilder<T extends Auth> extends StatefulWidget {
  final OnAuthBuilder builder;

  const AuthBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<AuthBuilder<T>> createState() => _AuthBuilderState<T>();
}

class _AuthBuilderState<T extends Auth> extends State<AuthBuilder<T>> {
  AuthState state = AuthState.unauthenticated;

  void _onStatus(BuildContext context, AuthState state) {
    setState(() => this.state = state);
  }

  @override
  Widget build(context) {
    return AuthObserver(
      onStatus: _onStatus,
      child: widget.builder(context, state),
    );
  }
}
