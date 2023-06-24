import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  final local = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => local);

  locator.registerLazySingleton<AuthDataSource>(() {
    return AuthDataSourceImpl();
  });
  locator.registerLazySingleton<LocalDataSource<Authenticator>>(() {
    return LocalAuthenticatorDataSource();
  });

  locator.registerLazySingleton<AuthRepository>(() {
    return AuthRepositoryImpl(
      source: locator(),
    );
  });
  locator.registerLazySingleton<LocalDataRepository<Authenticator>>(() {
    return LocalDataRepositoryImpl<Authenticator>(
      local: locator(),
    );
  });

  locator.registerLazySingleton<AuthHandler>(() {
    return AuthHandlerImpl(repository: locator());
  });

  locator.registerLazySingleton<DataHandler<Authenticator>>(() {
    return LocalDataHandlerImpl<Authenticator>(repository: locator());
  });

  locator.registerFactory<DefaultAuthController<Authenticator>>(() {
    return DefaultAuthController(
      authHandler: locator(),
      dataHandler: locator(),
    );
  });
  await locator.allReady();
}

class LocalAuthenticatorDataSource extends LocalDataSourceImpl<Authenticator> {
  LocalAuthenticatorDataSource({
    super.path = "authenticators",
  });

  @override
  Authenticator build(source) {
    return Authenticator.from(source);
  }
}
