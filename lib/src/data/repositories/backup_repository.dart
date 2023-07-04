part of 'repositories.dart';

class BackupRepositoryImpl<T extends Authenticator>
    extends BackupRepository<T> {
  final BackupDataSource<T> source;

  BackupRepositoryImpl({
    BackupDataSource<T>? source,
    SharedPreferences? preferences,
  }) : source = source ?? BackupDataSourceImpl<T>(preferences: preferences);

  @override
  Future<T> getCache() => source.getCache();

  @override
  Future<bool> setCache(T data) => source.setCache(data);

  @override
  Future<bool> removeCache() => source.removeCache();

  @override
  Future<void> onCreated(T data) async {}

  @override
  Future<void> onDeleted(String id) async {}
}
