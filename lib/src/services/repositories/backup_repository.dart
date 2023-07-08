part of 'repositories.dart';

abstract class BackupRepository {
  Future<Auth> getCache();

  Future<bool> setCache(Auth data);

  Future<bool> removeCache();

  Future<void> onCreated(Auth data);

  Future<void> onDeleted(String id);
}
