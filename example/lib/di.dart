import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController<Authenticator>>(() {
    return AuthController(

    );
  });
  await locator.allReady();
}

class UserBackupSource extends BackupDataSource<Authenticator> {
  final UserDataSource source;

  UserBackupSource(this.source);

  @override
  Authenticator build(source) {
    return Authenticator.from(source);
  }

  @override
  Future<Authenticator> getCache(String? id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<bool> removeCache(String? id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<bool> setCache(Authenticator data) {
    // TODO: implement set
    throw UnimplementedError();
  }
}

class UserDataSource extends FireStoreDataSourceImpl<Authenticator> {
  UserDataSource({
    super.path = "auth_users",
  });

  @override
  Authenticator build(source) {
    return Authenticator.from(source);
  }
}
