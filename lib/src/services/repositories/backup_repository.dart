part of 'repositories.dart';

abstract class BackupRepository<T extends Auth> {
  Future<T> getCache();

  Future<bool> setCache(T data);

  Future<bool> removeCache();

  Future<void> onCreated(T data);

  Future<void> onDeleted(String id);
}
