part of 'sources.dart';

abstract class BackupSource<T extends Auth> {
  BackupSource({
    SharedPreferences? preferences,
  }) : _db = preferences;

  SharedPreferences? _db;

  Future<SharedPreferences> get preferences async =>
      _db ??= await SharedPreferences.getInstance();

  final String key = "uid";

  Future<T> getCache();

  Future<bool> setCache(T data);

  Future<bool> removeCache();

  Future<void> onCreated(T data);

  Future<void> onDeleted(String id);

  T build(dynamic source);
}
