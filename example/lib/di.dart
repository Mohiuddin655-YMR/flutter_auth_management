import 'package:auth_management/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController<Authenticator>>(() {
    return AuthController();
  });
  await locator.allReady();
}
