part of 'sources.dart';

abstract class BackupDataSource<T extends Authenticator> {
  BackupDataSource({
    SharedPreferences? preferences,
  }) : _db = preferences;

  SharedPreferences? _db;

  Future<SharedPreferences> get preferences async =>
      _db ??= await SharedPreferences.getInstance();

  Future<T> getCache();

  Future<bool> setCache(T data);

  Future<bool> removeCache();

  Future<void> onCreated(T data);

  Future<void> onDeleted(String id);

  T build(dynamic source);
}
