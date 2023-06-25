import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController<Authenticator>>(() {
    return AuthController.remotely(
      remote: RemoteAuthDataSource(),
    );
  });
  await locator.allReady();
}

class RemoteAuthDataSource extends FireStoreDataSourceImpl<Authenticator> {
  RemoteAuthDataSource({
    super.path = "authenticators",
  });

  @override
  Authenticator build(source) {
    return Authenticator.from(source);
  }
}
