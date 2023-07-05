part of 'repositories.dart';

class BackupRepositoryImpl<T extends Auth> extends BackupRepository<T> {
  final BackupSource<T> source;

  BackupRepositoryImpl({
    BackupSource<T>? source,
    SharedPreferences? preferences,
  }) : source = source ?? KeepDataSource<T>(preferences: preferences);

  @override
  Future<T> getCache() => source.getCache();

  @override
  Future<bool> setCache(T data) => source.setCache(data);

  @override
  Future<bool> removeCache() => source.removeCache();

  @override
  Future<void> onCreated(T data) => source.onCreated(data);

  @override
  Future<void> onDeleted(String id) => source.onDeleted(id);
}
