part of 'handlers.dart';

abstract class BackupHandler<T extends Authenticator> {
  Future<T> getCache(String? id);

  Future<bool> setCache(T data);

  Future<bool> remove(String? id);

  Future<void> clearCache() async {}
}
