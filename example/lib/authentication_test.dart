import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationTest extends StatefulWidget {
  const AuthenticationTest({Key? key}) : super(key: key);

  @override
  State<AuthenticationTest> createState() => _AuthenticationTestState();
}

class _AuthenticationTestState extends State<AuthenticationTest> {
  late AuthController<Authenticator> controller = context.read();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                      email: "example@gmail.com",
                      password: "123456",
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
                      username: "username",
                      password: "123456",
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
                      email: "example@gmail.com",
                      password: "123456",
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text("SignUp with Username"),
                  onPressed: () => controller.signUpByUsername(
                    UsernameAuthenticator(
                      username: "username",
                      password: "123456",
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
            BlocConsumer<AuthController<Authenticator>, AuthResponse<Authenticator>>(
              builder: (context, state) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  color: Colors.grey.withAlpha(50),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.beautify,
                    textAlign: TextAlign.center,
                  ),
                );
              },
              listener: (context, state) {
                if (state.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error),
                  ));
                } else if (state.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Valid Data"),
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
