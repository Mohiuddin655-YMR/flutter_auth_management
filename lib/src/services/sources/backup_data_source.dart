import 'package:flutter_andomie/core.dart';

import '../../models/auth.dart';

abstract class BackupDataSource<T extends Auth> {
  BackupDataSource({
    LocalDatabase? database,
  }) : _db = database;

  LocalDatabase? _db;

  Future<LocalDatabase> get database async => _db ??= await LocalDatabaseImpl.I;

  final String key = AuthKeys.key;

  Future<T?> get cache;

  Future<bool> set(T? data);

  Future<bool> update(Map<String, dynamic> data);

  Future<bool> clear();

  Future<T?> onFetchUser(String id);

  Future<void> onCreateUser(T data);

  Future<void> onUpdateUser(String id, Map<String, dynamic> data);

  Future<void> onDeleteUser(String id);

  T build(Map<String, dynamic> source);
}
