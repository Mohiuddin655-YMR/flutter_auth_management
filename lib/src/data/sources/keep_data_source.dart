part of 'sources.dart';

class KeepDataSource<T extends Auth> extends BackupDataSourceImpl<T> {
  KeepDataSource({
    super.database,
  });

  @override
  Future<T?> onFetchUser(String id) async => null;

  @override
  Future<void> onCreateUser(T data) async {}

  @override
  Future<void> onDeleteUser(String id) async {}

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) async {}

  @override
  T build(Map<String, dynamic> source) => Auth.from(source) as T;
}
