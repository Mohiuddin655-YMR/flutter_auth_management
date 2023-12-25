part of 'sources.dart';

class KeepDataSource extends BackupDataSourceImpl {
  KeepDataSource({
    super.database,
  });

  @override
  Future<void> onCreated(Authorizer data) async {}

  @override
  Future<void> onDeleted(String id) async {}
}
