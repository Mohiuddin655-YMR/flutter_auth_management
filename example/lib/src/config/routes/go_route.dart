import 'package:auth_management/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_andomie/core.dart';
import 'package:flutter_app_navigator/app_navigator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../index.dart';

class AppRouter {
  AppRouter._();

  static AppRouter get I => AppRouter._();

  List<String> ignoreRedirections = [
    '${AuthScreens.route}/:name',
    SplashScreens.route,
  ];

  bool isRedirection(String? path) {
    return !ignoreRedirections.contains(path);
  }

  GoRouter get router => GoRouter(
        initialLocation: SplashScreens.route,
        errorBuilder: (context, state) => const ErrorScreen(),
        redirect: (context, state) async {
          if (kIsWeb && isRedirection(state.fullPath)) {
            final bool loggedIn = await locator<AuthHandler>().isSignIn();
            if (!loggedIn) {
              return AuthScreens.route;
            }
          }
          return null;
        },
        routes: <RouteBase>[
          GoRoute(
            path: SplashScreens.route,
            builder: (context, state) {
              return const SplashActivity();
            },
          ),
          GoRoute(
            name: AuthScreens.route,
            path: '${AuthScreens.route}/:name',
            builder: (context, state) {
              var screen = state.pathParameters.getValue<String>("name");
              var back = state.uri.queryParameters.getValue<String>("back");
              return BlocProvider(
                create: (context) => locator<CustomAuthController>(),
                child: AuthActivity(
                  isFromWelcome: back.equals("true"),
                  screen: screen.equals("sign_up")
                      ? AuthScreens.signUp
                      : AuthScreens.signIn,
                ),
              );
            },
          ),
          GoRoute(
            path: DashboardScreens.route,
            builder: (context, state) {
              var data = state.extra;
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => locator<DashboardController>(),
                  ),
                ],
                child: DashboardActivity(
                  screen: data("screen", DashboardScreens.none),
                ),
              );
            },
          ),
        ],
      );
}

extension AppRouterPathExtension on String {
  String get withSlash => "/$this";

  String withParent(String parent) {
    return "/$parent/$this";
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Error"),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            "No screen found!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
