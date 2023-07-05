part of 'handlers.dart';

abstract class BackupHandler<T extends Auth> {
  Future<T> getCache();

  Future<bool> setCache(T data);

  Future<bool> removeCache();

  Future<void> onCreated(T data);

  Future<void> onDeleted(String id);
}
