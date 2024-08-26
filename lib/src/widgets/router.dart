import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../models/auth.dart';
import '../models/auth_status.dart';

class AuthRouter<T extends Auth> extends StatelessWidget {
  final String initialRoute;
  final String authenticatedRoute;
  final String unauthenticatedRoute;
  final Widget Function(BuildContext context, String route) builder;

  const AuthRouter({
    super.key,
    required this.builder,
    required this.initialRoute,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.isSignIn<T>(),
      builder: (context, snapshot) {
        final state = snapshot.data?.state ?? AuthStatus.unauthorized;
        if (state.isAuthenticated) {
          return builder(context, authenticatedRoute);
        } else if (state.isUnauthenticated) {
          return builder(context, unauthenticatedRoute);
        } else {
          return builder(context, initialRoute);
        }
      },
    );
  }
}
