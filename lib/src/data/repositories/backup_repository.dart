part of 'repositories.dart';

class BackupRepositoryImpl extends BackupRepository {
  final BackupDataSource source;

  BackupRepositoryImpl({
    BackupDataSource? source,
    LocalDatabase? database,
  }) : source = source ?? KeepDataSource(database: database);

  @override
  Future<Authorizer?> getCache() => source.getCache();

  @override
  Future<bool> setCache(Authorizer? data) => source.setCache(data);

  @override
  Future<bool> removeCache() => source.removeCache();

  @override
  Future<void> onCreated(Authorizer data) => source.onCreated(data);

  @override
  Future<void> onDeleted(String id) => source.onDeleted(id);
}
