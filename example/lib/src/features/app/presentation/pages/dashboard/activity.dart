import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_navigator/app_navigator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../index.dart';

class DashboardActivity extends StatefulWidget {
  final DashboardScreens? screen;

  const DashboardActivity({
    super.key,
    this.screen,
  });

  static void go<T>(
    BuildContext context,
    DashboardScreens screen, [
    T? data,
  ]) {
    AppNavigator.of(context).go(
      DashboardScreens.route,
      path: screen.name,
      extra: {
        "data": data,
      },
    );
  }

  static void goHome<T>(
    BuildContext context,
    DashboardScreens screen, [
    T? data,
  ]) {
    AppNavigator.of(context).goHome(
      DashboardScreens.route,
      path: screen.name,
      extra: {
        "data": data,
      },
    );
  }

  @override
  State<DashboardActivity> createState() => _DashboardActivityState();
}

class _DashboardActivityState extends State<DashboardActivity> {
  late final DashboardScreens _screen = widget.screen ?? DashboardScreens.none;

  Map<DashboardScreens, Widget> fragments = {
    DashboardScreens.none: const HomeFragment(),
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardController, AuthResponse>(
      listener: (context, state) async {
        if (state.isUnauthenticated) {
          AuthActivity.goHome(context, AuthScreens.signIn);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: fragments[_screen] ?? const HomeFragment(),
        );
      },
    );
  }
}
