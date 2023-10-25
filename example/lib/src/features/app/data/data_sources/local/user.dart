import 'package:auth_management/auth_management.dart';
import 'package:data_management/core.dart';

import '../../../../../../index.dart';

class UserBackupSource extends BackupSourceImpl {
  final RemoteDataHandler<User> handler;

  UserBackupSource(this.handler);

  @override
  Future<void> onCreated(Auth data) => handler.insert(User.fromAuth(data));

  @override
  Future<void> onDeleted(String id) => handler.delete(id);
}
