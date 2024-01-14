import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();

  bool loading = false;

  void login(AuthController<UserModel> controller) async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signInByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(indicatorVisible);
  }

  void register(AuthController<UserModel> controller) async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signUpByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(indicatorVisible);
  }

  void indicatorVisible(bool value) {
    setState(() => loading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                TextField(
                  controller: etEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: etPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Password",
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: AuthBuilder<UserModel>(
                    action: AuthActions.signInByEmail,
                    builder: (context, controller, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ElevatedButton(
                        onPressed: () => login(controller),
                        child: const Text("Login"),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AuthBuilder<UserModel>(
                    action: AuthActions.signUpByEmail,
                    builder: (context, controller, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ElevatedButton(
                        onPressed: () => register(controller),
                        child: const Text("Register"),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
