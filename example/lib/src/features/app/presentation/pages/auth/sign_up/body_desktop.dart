import 'dart:io';

import 'package:app_color/app_color.dart';
import 'package:auth_management/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../../index.dart';

class AuthSignUpDesktopBody extends StatefulWidget {
  final AuthSignInHandler onSignIn;
  final AuthSignInHandler onSignInWithApple;
  final AuthSignInHandler onSignInWithGoogle;
  final AuthSignInHandler onSignInWithFacebook;
  final AuthSignUpHandler onSignUp;

  const AuthSignUpDesktopBody({
    Key? key,
    required this.onSignIn,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
    required this.onSignInWithFacebook,
    required this.onSignUp,
  }) : super(key: key);

  @override
  State<AuthSignUpDesktopBody> createState() => _AuthSignUpDesktopBodyState();
}

class _AuthSignUpDesktopBodyState extends State<AuthSignUpDesktopBody> {
  late EmailEditingController email;
  late PhoneEditingController phone;
  late PasswordEditingController password;

  @override
  void initState() {
    email = EmailEditingController();
    phone = PhoneEditingController();
    password = PasswordEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearLayout(
      orientation: Axis.horizontal,
      children: [
        LinearLayout(
          flex: 1,
          scrollable: true,
          orientation: Axis.vertical,
          crossGravity: CrossAxisAlignment.center,
          children: [
            LinearLayout(
              widthMax: 420,
              orientation: Axis.vertical,
              crossGravity: CrossAxisAlignment.center,
              paddingTop: 100,
              paddingHorizontal: 32,
              paddingBottom: 24,
              children: [
                const TextView(
                  text: "Welcome back",
                  textColor: Colors.black,
                  textSize: 24,
                  textFontWeight: FontWeight.w500,
                ),
                const TextView(
                  marginTop: 16,
                  text: "Welcome back! Please enter your details.",
                  textColor: Colors.grey,
                  textSize: 16,
                ),
                const SizedBox(height: 50),
                // const TextView(
                //   width: double.infinity,
                //   text: "Create a new account",
                //   textAlign: TextAlign.start,
                //   textColor: Colors.black,
                //   fontWeight: FontWeight.bold,
                //   textSize: 24,
                //   marginVertical: 24,
                // ),
                EmailField(
                  hint: "Enter your email",
                  controller: email,
                ),
                PhoneField(
                  controller: phone,
                  textCode: "+880",
                  hintCode: "+880",
                  hintNumber: "Enter phone number",
                ),
                PasswordField(
                  hint: "Enter your password",
                  controller: password,
                  margin: EdgeInsets.zero,
                ),
                CreateAccountTextView(
                  width: double.infinity,
                  textAlign: TextAlign.end,
                  padding: const EdgeInsets.all(12),
                  text: "Already have an account?  ",
                  buttonText: "Login here",
                  textColor: AppColors.primary,
                  textWeight: FontWeight.w500,
                  onPressed: () => widget.onSignIn(
                    AuthInfo(
                      email: email.text,
                      password: password.text,
                      phone: phone.number.numberWithCode,
                    ),
                  ),
                ),
                BlocBuilder<CustomAuthController, AuthResponse>(
                  builder: (context, state) {
                    return StackLayout(
                      width: double.infinity,
                      marginVertical: 24,
                      height: 65,
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          )
                        else
                          AppButton(
                            text: "Sign up",
                            borderRadius: 25,
                            primary: AppColors.primary,
                            onExecute: () => widget.onSignUp.call(
                              AuthInfo(
                                email: email.text,
                                password: password.text,
                                phone: phone.number.numberWithCode,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const OrText(),
                OAuthButton(
                  text: "Login With Google",
                  background: AppColors.primary,
                  icon: AppIcons.google,
                  onClick: (context) => widget.onSignInWithGoogle.call(
                    AuthInfo(
                      email: email.text,
                      password: password.text,
                    ),
                  ),
                ),
                // OAuthButton(
                //   text: "Login With Facebook",
                //   background: AppColors.secondary,
                //   icon: AppIcons.facebook,
                //   onClick: (context) => widget.onSignInWithFacebook.call(
                //     AuthInfo(
                //       email: email.text,
                //       password: password.text,
                //     ),
                //   ),
                // ),
                if (!kIsWeb && Platform.isIOS)
                  OAuthButton(
                    text: "Login With Apple",
                    background: AppColors.secondary,
                    icon: AppIcons.apple,
                    onClick: (context) => widget.onSignInWithApple.call(
                      AuthInfo(
                        email: email.text,
                        password: password.text,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        LinearLayout(
          flex: 1,
          borderRadiusTL: 35,
          borderRadiusBL: 35,
          background: AppColors.ternary.b20.withOpacity(0.2),
          crossGravity: CrossAxisAlignment.center,
          mainGravity: MainAxisAlignment.center,
          gravity: Alignment.center,
          children: [
            TextView(
              marginTop: 24,
              marginBottom: 24,
              textAlign: TextAlign.center,
              textColor: Colors.grey,
              textSize: 12,
              text:
                  'Powered by Tech Analytica Limited || Version ${locator<PackageInfo>().version}',
            ),
          ],
        ),
      ],
    );
  }
}
