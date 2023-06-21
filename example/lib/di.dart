import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {

  final local = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => local);

  locator.registerLazySingleton<AuthDataSource>(() {
    return AppAuthDataSource();
  });
  locator.registerLazySingleton<LocalDataSource<AuthInfo>>(() {
    return AuthenticatorDataSource();
  });

  locator.registerLazySingleton<LocalDataRepository<AuthInfo>>(() {
    return AuthenticatorRepository(local: locator());
  });

  locator.registerLazySingleton<LocalDataHandler<AuthInfo>>(() {
    return AuthenticatorHandler(repository: locator());
  });

  locator.registerFactory<AuthController>(() {
    return AuthController(
      authHandler: locator(),
      dataHandler: locator(),
    );
  });
  await locator.allReady();
}
