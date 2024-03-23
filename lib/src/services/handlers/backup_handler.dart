import '../../models/auth.dart';

abstract class BackupHandler<T extends Auth> {
  Future<T?> get cache;

  Future<T?> get([bool remotely = false]);

  Future<bool> set(T? data);

  Future<bool> setAsLocal(T? data);

  Future<bool> update(Map<String, dynamic> data);

  Future<bool> updateAsLocal({
    required String id,
    Map<String, dynamic> creates = const {},
    Map<String, dynamic> updates = const {},
    bool updateMode = false,
  });

  Future<bool> clear();

  Future<T?> onFetchUser(String id);

  Future<void> onCreateUser(T data);

  Future<void> onUpdateUser(String id, Map<String, dynamic> data);

  Future<void> onDeleteUser(String id);

  T build(Map<String, dynamic> source);
}
