import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../index.dart';

typedef AuthCreateHandler = Function(AuthInfo data);
typedef AuthForgotHandler = Function(AuthInfo data);

typedef AuthSignInHandler = Function(AuthInfo data);
typedef AuthSignUpHandler = Function(AuthInfo data);

class AuthFragment extends StatefulWidget {
  final bool isFromWelcome;
  final AuthScreens screen;

  const AuthFragment({
    Key? key,
    required this.isFromWelcome,
    required this.screen,
  }) : super(key: key);

  @override
  State<AuthFragment> createState() => _AuthFragmentState();
}

class _AuthFragmentState extends State<AuthFragment> {
  late CustomAuthController controller;

  @override
  void initState() {
    controller = context.read<CustomAuthController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.screen) {
      case AuthScreens.none:
      case AuthScreens.signIn:
        return AuthSignInFragment(
          onSignIn: controller.signIn,
          onSignInWithApple: controller.signInWithApple,
          onSignInWithBiometric: controller.signInWithBiometric,
          onSignInWithGoogle: controller.signInWithGoogle,
          onSignInWithFacebook: controller.signInWithFacebook,
          onCreateAccount: (data) => AuthActivity.go(
            context,
            AuthScreens.signUp,
          ),
          onForgetPassword: (data) => AuthActivity.go(
            context,
            AuthScreens.forgotPassword,
          ),
        );
      case AuthScreens.signUp:
        return AuthSignUpFragment(
          onSignUp: controller.signUp,
          onSignInWithApple: controller.signInWithApple,
          onSignInWithGoogle: controller.signInWithGoogle,
          onSignInWithFacebook: controller.signInWithFacebook,
          onSignIn: (data) => AuthActivity.go(
            context,
            AuthScreens.signIn,
          ),
        );
      case AuthScreens.forgotPassword:
        return AuthForgotPasswordFragment(
          onForgot: controller.forgot,
        );
    }
  }
}
