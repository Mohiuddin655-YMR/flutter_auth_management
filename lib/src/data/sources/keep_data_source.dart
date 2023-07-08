part of 'sources.dart';

class KeepDataSource extends BackupSourceImpl {
  KeepDataSource({
    super.database,
  });

  @override
  Future<void> onCreated(Auth auth) async {}

  @override
  Future<void> onDeleted(String id) async {}
}
