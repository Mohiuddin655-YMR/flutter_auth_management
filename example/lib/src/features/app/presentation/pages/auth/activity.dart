import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_navigator/app_navigator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../index.dart';

class AuthActivity extends StatelessWidget {
  final bool? isFromWelcome;
  final AuthScreens? screen;

  const AuthActivity({
    super.key,
    this.isFromWelcome,
    this.screen,
  });

  static void go<T>(
    BuildContext context,
    AuthScreens screen, [
    T? data,
  ]) {
    AppNavigator.of(context).go(
      AuthScreens.route,
      path: screen.name,
      extra: {
        "data": data,
      },
    );
  }

  static void goHome<T>(
    BuildContext context,
    AuthScreens screen, [
    T? data,
  ]) {
    AppNavigator.of(context).goHome(
      AuthScreens.route,
      path: screen.name,
      extra: {
        "data": data,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CustomAuthController, AuthResponse>(
        listener: (context, state) {
          if (state.isError || state.isMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.isMessage ? state.message : state.error),
              ),
            );
          }
          if (state.isAuthenticated) {
            AppNavigator.of(context).goHome(
              DashboardScreens.route,
              extra: state.data,
            );
          }
        },
        builder: (context, state) {
          return AuthFragment(
            isFromWelcome: isFromWelcome ?? false,
            screen: screen ?? AuthScreens.signIn,
          );
        },
      ),
    );
  }
}
