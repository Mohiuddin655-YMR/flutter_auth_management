import 'dart:io';

import 'package:app_color/app_color.dart';
import 'package:auth_management/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_androssy/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../../index.dart';

class AuthSignInDesktopBody extends StatefulWidget {
  final AuthSignInHandler onSignIn;
  final AuthSignInHandler onSignInWithApple;
  final AuthSignInHandler onSignInWithGoogle;
  final AuthSignInHandler onSignInWithFacebook;
  final AuthForgotHandler onForgetPassword;
  final AuthCreateHandler onCreateAccount;

  const AuthSignInDesktopBody({
    Key? key,
    required this.onSignIn,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
    required this.onSignInWithFacebook,
    required this.onForgetPassword,
    required this.onCreateAccount,
  }) : super(key: key);

  @override
  State<AuthSignInDesktopBody> createState() => _AuthSignInDesktopBodyState();
}

class _AuthSignInDesktopBodyState extends State<AuthSignInDesktopBody> {
  late EmailEditingController email;
  late PasswordEditingController password;

  @override
  void initState() {
    email = EmailEditingController();
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
              paddingTop: 120,
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
                EmailField(
                  controller: email,
                  hint: "Enter your email",
                ),
                PasswordField(
                  hint: "Enter your password",
                  controller: password,
                  margin: EdgeInsets.zero,
                ),
                // AppTextButton(
                //   width: double.infinity,
                //   textAlign: TextAlign.end,
                //   fontWeight: FontWeight.bold,
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 12,
                //     horizontal: 8,
                //   ),
                //   text: "Forget password?",
                //   onPressed: () => widget.onForgetPassword.call(AuthInfo(
                //     email: email.text,
                //     password: password.text,
                //   )),
                // ),
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
                            text: "Sign In",
                            borderRadius: 25,
                            primary: AppColors.primary,
                            onPressed: () => widget.onSignIn.call(
                              AuthInfo(
                                email: email.text,
                                password: password.text,
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
                CreateAccountTextView(
                  width: double.infinity,
                  textAlign: TextAlign.center,
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(24),
                  text: "Don't have an account ?  ",
                  textWeight: FontWeight.w500,
                  textColor: AppColors.primary.withAlpha(200),
                  buttonText: "Sign Up",
                  buttonTextColor: AppColors.secondary,
                  onPressed: () => widget.onCreateAccount.call(AuthInfo(
                    email: email.text,
                    password: password.text,
                  )),
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
                  'Powered by Picon Soft Lab || Version ${locator<PackageInfo>().version}',
            ),
          ],
        ),
      ],
    );
  }
}
