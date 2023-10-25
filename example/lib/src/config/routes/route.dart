import 'package:flutter/material.dart';
import 'package:flutter_app_navigator/app_navigator.dart';

import '../../../index.dart';

class AppRouter extends AppRouteGenerator {
  const AppRouter._();

  static AppRouter get I => const AppRouter._();

  @override
  AppRouteConfig get config {
    return const AppRouteConfig(
      animationTime: 500,
    );
  }

  @override
  Map<String, RouteBuilder> routes() {
    return {
      SplashScreens.route: splash,
      AuthScreens.route: auth,
      DashboardScreens.route: dashboard,
      // ...
      // ...
      // ...
    };
  }

  @override
  Widget onDefault(BuildContext context, Object? data) {
    return dashboard(context, data);
  }

  Widget splash(BuildContext context, Object? data) {
    return const SplashActivity();
  }

  Widget auth(BuildContext context, Object? data) {
    return const AuthActivity();
  }

  Widget dashboard(BuildContext context, Object? data) {
    return const DashboardActivity();
  }
}
