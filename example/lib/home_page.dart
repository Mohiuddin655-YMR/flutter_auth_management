import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _signOut(AuthController<UserModel> controller) {
    controller.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Home",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AuthBuilder<UserModel>(
                  action: AuthActions.signOut,
                  builder: (context, controller, state) {
                    return ElevatedButton(
                      onPressed: () => _signOut(controller),
                      child: const Text("Logout"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
