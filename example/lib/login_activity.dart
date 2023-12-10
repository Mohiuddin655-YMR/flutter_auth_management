import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_andomie/core.dart';
import 'package:flutter_androssy/core.dart';
import 'package:flutter_androssy/widgets.dart';

class LoginActivity extends AndrossyActivity<LoginController> {
  const LoginActivity({
    super.key,
    super.statusBar = false,
  });

  @override
  LoginController init(BuildContext context) {
    return LoginController();
  }

  @override
  Widget? onCreateTitle(BuildContext context) {
    return const TextView(text: "Login");
  }

  @override
  Widget onCreate(BuildContext context, AndrossyInstance instance) {
    return EditLayout(
      width: double.infinity,
      height: double.infinity,
      gravity: Alignment.center,
      padding: 32,
      children: [
        EditText(
          controller: controller.etEmail,
          inputType: TextInputType.emailAddress,
          hint: "Email",
          onValidator: Validator.isValidEmail,
        ),
        EditText(
          marginTop: 24,
          controller: controller.etPassword,
          inputType: TextInputType.visiblePassword,
          hint: "Password",
          onValidator: Validator.isValidPassword,
        ),
        Button(
          rippleColor: Colors.black45,
          borderRadius: 24,
          width: double.infinity,
          marginTop: 32,
          controller: controller.btnSubmit,
          text: "Login",
        ),
        Button(
          marginTop: 24,
          rippleColor: Colors.black45,
          borderRadius: 24,
          width: double.infinity,
          controller: controller.btnRegister,
          text: "Register",
        ),
      ],
    );
  }
}

class LoginController extends AndrossyController {
  late AuthController controller;

  final etEmail = EditTextController();
  final etPassword = EditTextController();
  final btnSubmit = ButtonController();
  final btnRegister = ButtonController();

  @override
  void onInit(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller = AuthProvider.controllerOf(context);
    });
    super.onInit(context);
  }

  @override
  void onListener(BuildContext context) {
    btnSubmit.setOnClickListener(login);
    btnRegister.setOnClickListener(register);
  }

  void login(BuildContext context) async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signInByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(btnSubmit.setIndicatorVisible);
  }

  void register(BuildContext context) async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signUpByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(btnRegister.setIndicatorVisible);
  }
}
