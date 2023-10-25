import 'package:flutter/material.dart';
import 'package:flutter_androssy/core.dart';

import 'index.dart';

Future<void> main() async {
  await diInit();
  runApp(AndrossyProvider(
    androssy: const Androssy(
      settings: AndrossySettings(
        locale: Locale("en"),
        theme: ThemeMode.system,
      ),
    ),
    child: const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AndrossyBuilder(
      builder: (context, value) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppInfo.name,
          locale: value.settings.locale,
          themeMode: value.settings.theme,
          theme: theme.light,
          darkTheme: theme.dark,
          routerConfig: AppRouter.I.router,
          // initialRoute: SplashScreens.route,
          // onGenerateRoute: AppRouter.I.generate,
        );
      },
    );
  }
}
