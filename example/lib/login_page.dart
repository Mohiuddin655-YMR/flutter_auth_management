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
  final etName = TextEditingController();
  final etEmail = TextEditingController();
  final etPhone = TextEditingController();
  final etPassword = TextEditingController();
  final etOTP = TextEditingController();
  String? token;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
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
            controller: etName,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: "Name",
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
          const SizedBox(height: 24),
          TextField(
            controller: etPhone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Phone",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etOTP,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "OTP",
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByEmail,
              child: const Text("Login (Email)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByEmail,
              child: const Text("Sign Up (Email)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByUsername,
              child: const Text("Login (Username)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByUsername,
              child: const Text("Sign Up (Username)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByPhone,
              child: const Text("Phone"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByOtp,
              child: const Text("OTP"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: signInByApple,
                  child: const Text("Apple"),
                ),
                ElevatedButton(
                  onPressed: signInByBiometric,
                  child: const Text("Biometric"),
                ),
                ElevatedButton(
                  onPressed: signInByFacebook,
                  child: const Text("Facebook"),
                ),
                ElevatedButton(
                  onPressed: signInByGithub,
                  child: const Text("Github"),
                ),
                ElevatedButton(
                  onPressed: signInByGoogle,
                  child: const Text("Google"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void signInByEmail() async {
    log("AUTH : login");
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  void signUpByEmail() async {
    final name = etName.text;
    final email = etEmail.text;
    final password = etPassword.text;
    context.signUpByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
      name: name, // Optional
    ));
  }

  void signInByUsername() {
    final name = etName.text;
    final password = etPassword.text;
    context.signInByUsername<UserModel>(UsernameAuthenticator(
      username: name,
      password: password,
    ));
  }

  void signUpByUsername() {
    final name = etName.text;
    final password = etPassword.text;
    context.signUpByUsername<UserModel>(UsernameAuthenticator(
      username: name,
      password: password,
      name: name, // Optional
    ));
  }

  void signInByPhone() async {
    final name = etName.text;
    final phone = etPhone.text;
    context.signInByPhone<UserModel>(
      PhoneAuthenticator(phone: phone, name: name),
      onCodeSent: (verId, refreshTokenId) {
        token = verId;
      },
    );
  }

  void signInByOtp() async {
    final name = etName.text;
    final phone = etPhone.text;
    final code = etOTP.text;
    context.signInByOtp<UserModel>(OtpAuthenticator(
      token: token ?? "",
      smsCode: code,
      name: name,
      phone: phone,
    ));
  }

  void signInByApple() {
    context.signInByApple<UserModel>();
  }

  void signInByBiometric() {
    context.signInByBiometric<UserModel>();
  }

  void signInByFacebook() {
    context.signInByFacebook<UserModel>();
  }

  void signInByGithub() {
    context.signInByGithub<UserModel>();
  }

  void signInByGoogle() {
    context.signInByGoogle<UserModel>();
  }
}
