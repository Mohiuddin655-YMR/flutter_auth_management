part of 'handlers.dart';

abstract class BackupHandler {
  Future<Authorizer?> getCache();

  Future<bool> setCache(Authorizer? data);

  Future<bool> removeCache();

  Future<void> onCreated(Authorizer data);

  Future<void> onDeleted(String id);
}
