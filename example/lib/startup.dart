import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'user.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  void _response(BuildContext context, AuthResponse<UserModel> response) {}

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showLoading(BuildContext context, bool loading) {}

  void _stateChange(BuildContext context, AuthState state) {
    if (state.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) {
        return const HomePage();
      }), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthObserver<UserModel>(
        onError: _showSnackBar,
        onMessage: _showSnackBar,
        onLoading: _showLoading,
        onResponse: _response,
        onStateChange: _stateChange,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return const LoginPage();
                  }));
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return const LoginPage();
                  }));
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
