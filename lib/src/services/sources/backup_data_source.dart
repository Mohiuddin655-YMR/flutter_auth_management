part of 'sources.dart';

abstract class BackupDataSource<T extends Authenticator> {
  BackupDataSource({
    SharedPreferences? preferences,
  }) : _db = preferences;

  SharedPreferences? _db;

  Future<SharedPreferences> get preferences async =>
      _db ??= await SharedPreferences.getInstance();

  Future<T> getCache(String? id);

  Future<bool> setCache(T data);

  Future<bool> removeCache(String? id);

  Future<void> clearCache() async {}

  T build(dynamic source);
}
