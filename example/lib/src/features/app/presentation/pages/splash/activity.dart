import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';
import 'package:flutter_app_navigator/app_navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../index.dart';
import 'splash_vie.dart';

class SplashActivity extends StatelessWidget {
  const SplashActivity({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppSplashView(
        title: AppInfo.name,
        titleAllCaps: true,
        titleExtraSize: 2,
        titleSize: 24,
        titleColor: AppColors.secondary,
        subtitle: AppInfo.description,
        logo: AppInfo.logo,
        logoColor: AppColors.primary,
        onRoute: (context) {
          locator<AuthHandler>().isSignIn().then((value) {
            if (value) {
              AppNavigator.of(context).goHome(DashboardScreens.route);
            } else {
              AppNavigator.of(context).goHome(AuthScreens.route);
            }
          });
        },
      ),
    );
  }
}
