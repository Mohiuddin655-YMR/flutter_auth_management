import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();

  bool loading = false;

  void login() async {
    log("AUTH : login");
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  void register() async {
    final email = etEmail.text;
    final password = etPassword.text;
    context.signUpByEmail(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  void indicatorVisible(bool value) {
    setState(() => loading = value);
  }

  @override
  Widget build(BuildContext context) {
    // log("LOGIN PAGE");
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
                  child: ElevatedButton(
                    onPressed: () => login(),
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => register(),
                    child: const Text("Register"),
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
