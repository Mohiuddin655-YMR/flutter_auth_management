import 'package:flutter/material.dart';

import '../../../../../index.dart';

class AuthSignUpFragment extends StatelessWidget {
  static String route = "sign_up";
  final AuthSignInHandler onSignIn;
  final AuthSignInHandler onSignInWithApple;
  final AuthSignInHandler onSignInWithGoogle;
  final AuthSignInHandler onSignInWithFacebook;
  final AuthSignUpHandler onSignUp;

  const AuthSignUpFragment({
    Key? key,
    required this.onSignIn,
    required this.onSignInWithApple,
    required this.onSignInWithGoogle,
    required this.onSignInWithFacebook,
    required this.onSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: AuthSignUpMobileBody(
        onSignIn: onSignIn,
        onSignInWithApple: onSignInWithApple,
        onSignInWithGoogle: onSignInWithGoogle,
        onSignInWithFacebook: onSignInWithFacebook,
        onSignUp: onSignUp,
      ),
      desktop: AuthSignUpDesktopBody(
        onSignIn: onSignIn,
        onSignInWithApple: onSignInWithApple,
        onSignInWithGoogle: onSignInWithGoogle,
        onSignInWithFacebook: onSignInWithFacebook,
        onSignUp: onSignUp,
      ),
    );
  }
}
