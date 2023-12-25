part of 'sources.dart';

abstract class BackupDataSource {
  BackupDataSource({
    LocalDatabase? database,
  }) : _db = database;

  LocalDatabase? _db;

  Future<LocalDatabase> get database async => _db ??= await LocalDatabaseImpl.I;

  final String key = "uid";

  Future<Authorizer?> getCache();

  Future<bool> setCache(Authorizer? data);

  Future<bool> removeCache();

  Future<void> onCreated(Authorizer data);

  Future<void> onDeleted(String id);
}
