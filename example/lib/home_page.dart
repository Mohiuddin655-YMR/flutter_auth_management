import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _signOut() {
    context.signOut<UserModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthorizedUser<UserModel>(
          builder: (context, user) {
            return Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.email ?? "",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
