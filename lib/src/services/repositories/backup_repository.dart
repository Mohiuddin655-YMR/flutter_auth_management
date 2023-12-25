part of 'repositories.dart';

abstract class BackupRepository {
  Future<Authorizer?> getCache();

  Future<bool> setCache(Authorizer? data);

  Future<bool> removeCache();

  Future<void> onCreated(Authorizer data);

  Future<void> onDeleted(String id);
}
