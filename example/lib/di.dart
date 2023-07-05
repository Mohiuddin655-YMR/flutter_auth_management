import 'package:auth_management/core.dart';
import 'package:flutter_andomie/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController<Auth>>(() {
    return AuthController(backup: UserBackup());
  });
  await locator.allReady();
}

class UserBackup extends BackupSourceImpl<Auth> {
  @override
  Future<void> onCreated(Auth data) async {
    print("onCreated $data");
  }

  @override
  Future<void> onDeleted(String id) async {
    print("onDeleted $id");
  }

  @override
  Auth build(source) => Auth.from(source);
}
