part of 'repositories.dart';

class BackupRepositoryImpl extends BackupRepository {
  final BackupSource source;

  BackupRepositoryImpl({
    BackupSource? source,
    LocalDatabase? database,
  }) : source = source ?? KeepDataSource(database: database);

  @override
  Future<Auth> getCache() => source.getCache();

  @override
  Future<bool> setCache(Auth data) => source.setCache(data);

  @override
  Future<bool> removeCache() => source.removeCache();

  @override
  Future<void> onCreated(Auth data) => source.onCreated(data);

  @override
  Future<void> onDeleted(String id) => source.onDeleted(id);
}
