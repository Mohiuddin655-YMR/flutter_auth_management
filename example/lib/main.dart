import 'package:auth_management/core.dart';
import 'package:example/startup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    AuthProvider<UserModel>(
      controller: AuthController.getInstance<UserModel>(
        backup: UserBackup(),
      ),
      child: const Application(),
    ),
  );
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Auth Management',
      home: StartupPage(),
    );
  }
}
