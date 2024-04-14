import 'package:in_app_database/in_app_database.dart';

import '../../models/auth.dart';

abstract class AuthorizedDataSource<T extends Auth> {
  AuthorizedDataSource({
    InAppDatabase? database,
  }) : _db = database;

  InAppDatabase? _db;

  Future<InAppDatabase> get database async => _db ??= await InAppDatabaseImpl.I;

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
