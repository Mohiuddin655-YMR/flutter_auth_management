import 'dart:developer';

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

  void login() async {
    log("AUTH : login");
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  void register() async {
    final email = etEmail.text;
    final password = etPassword.text;
    context.signUpByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  @override
  Widget build(BuildContext context) {
    log("LOGIN PAGE");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Container(
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
      ),
    );
  }
}
