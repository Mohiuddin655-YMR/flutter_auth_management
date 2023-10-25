enum AuthScreens {
  forgotPassword("forgot_password", "Forgot Password"),
  signUp("sign_up", "Sign up"),
  signIn("sign_in", "Sign in"),
  none("/auth", "Auth");

  final String name;
  final String title;

  static String get route => none.name;

  const AuthScreens(this.name, this.title);
}
