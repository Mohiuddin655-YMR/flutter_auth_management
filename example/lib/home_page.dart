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

  void _updateUser() {
    context.updateAccount<UserModel>({
      UserKeys.i.biometric: true,
    });
  }

  void _updateBiometric(bool? value) {
    context.biometricEnable<UserModel>(value ?? false);
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showLoading(BuildContext context, bool loading) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loading ? "Loading..." : "Loaded")),
    );
  }

  void _status(BuildContext context, AuthState state) {
    if (state.isUnauthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthObserver<UserModel>(
          onError: _showSnackBar,
          onMessage: _showSnackBar,
          onLoading: _showLoading,
          onStatus: _status,
          child: AuthConsumer<UserModel>(
            builder: (context, value) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value?.email ?? "",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      value: value?.biometric ?? false,
                      onChanged: _updateBiometric,
                      title: const Text("Biometric settings"),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateUser,
                      child: const Text("Update"),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _signOut,
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
