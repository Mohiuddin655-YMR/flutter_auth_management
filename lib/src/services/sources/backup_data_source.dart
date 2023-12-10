part of 'sources.dart';

abstract class BackupDataSource {
  BackupDataSource({
    LocalDatabase? database,
  }) : _db = database;

  LocalDatabase? _db;

  Future<LocalDatabase> get database async => _db ??= await LocalDatabaseImpl.I;

  final String key = "uid";

  Future<Auth?> getCache();

  Future<bool> setCache(Auth? data);

  Future<bool> removeCache();

  Future<void> onCreated(Auth data);

  Future<void> onDeleted(String id);
}
