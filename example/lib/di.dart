import 'package:auth_management/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController<Authenticator>>(() {
    return AuthController.fromSource(
      messages: const AuthMessages(
        signIn: "Sign in successful!",
        signUp: "Sign up successful!",
        signOut: "Sign out successful!",
      ),
    );
  });
  await locator.allReady();
}
