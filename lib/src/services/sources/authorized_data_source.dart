import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth.dart';

abstract class AuthorizedDataSource<T extends Auth> {
  SharedPreferences? _db;

  Future<SharedPreferences> get database async {
    return _db ??= await SharedPreferences.getInstance();
  }

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
