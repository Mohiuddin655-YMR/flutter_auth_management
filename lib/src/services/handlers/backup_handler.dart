part of 'handlers.dart';

abstract class BackupHandler {
  Future<Auth> getCache();

  Future<bool> setCache(Auth data);

  Future<bool> removeCache();

  Future<void> onCreated(Auth data);

  Future<void> onDeleted(String id);
}
