import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:example/home_activity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_androssy/core.dart';

import 'login_activity.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      controller: AuthController(backup: UserBackup()),
      child: AndrossyApp(
        title: 'Auth Management',
        home: AuthObserver(
          listener: (context, value) {
            if (value.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value.error)),
              );
            }
            if (value.isMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value.message)),
              );
            }
          },
          builder: (context, value) {
            if (value.isAuthenticated) {
              return const HomeActivity();
            } else {
              return const LoginActivity();
            }
          },
        ),
      ),
    );
  }
}

class UserBackup extends BackupDataSourceImpl {
  @override
  Future<void> onCreated(Auth data) async {
    // Store authorized user data in remote server
    log("Authorized user data : $data");
  }

  @override
  Future<void> onDeleted(String id) async {
    // Clear unauthorized user data from remote server
    log("Unauthorized user id : $id");
  }
}
