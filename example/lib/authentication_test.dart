import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationTest extends StatefulWidget {
  const AuthenticationTest({Key? key}) : super(key: key);

  @override
  State<AuthenticationTest> createState() => _AuthenticationTestState();
}

class _AuthenticationTestState extends State<AuthenticationTest> {
  late AuthController<Auth> controller =
      context.read<AuthController<Auth>>();

  late TextEditingController email = TextEditingController();
  late TextEditingController username = TextEditingController();
  late TextEditingController password = TextEditingController();

  @override
  void initState() {
    email.text = "mohiuddin655.1@gmail.com";
    username.text = "mohiuddin655.1";
    password.text = "123456";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 24,
              ),
              child: Column(
                children: [
                  EditField(
                    controller: email,
                    hint: "Email",
                  ),
                  EditField(
                    controller: username,
                    hint: "Username",
                  ),
                  EditField(
                    controller: password,
                    hint: "Password",
                  ),
                ],
              ),
            ),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("SignIn with Apple"),
                  onPressed: () => controller.signInByApple(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Biometric"),
                  onPressed: () => controller.signInByBiometric(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Email"),
                  onPressed: () => controller.signInByEmail(
                    EmailAuthenticator(
                      email: email.text,
                      password: password.text,
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Facebook"),
                  onPressed: () => controller.signInByFacebook(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Github"),
                  onPressed: () => controller.signInByGithub(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Google"),
                  onPressed: () => controller.signInByGoogle(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Username"),
                  onPressed: () => controller.signInByUsername(
                    UsernameAuthenticator(
                      username: username.text,
                      password: password.text,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("SignUp with Email"),
                  onPressed: () => controller.signUpByEmail(
                    EmailAuthenticator(
                      email: email.text,
                      password: password.text,
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text("SignUp with Username"),
                  onPressed: () => controller.signUpByUsername(
                    UsernameAuthenticator(
                      username: username.text,
                      password: password.text,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Sign Out"),
                  onPressed: () => controller.signOut(),
                ),
              ],
            ),
            BlocConsumer<AuthController, AuthResponse<Auth>>(
              builder: (context, state) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  color: Colors.grey.withAlpha(50),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.toString(),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              listener: (context, state) {
                if (state.isMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const EditField({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}
