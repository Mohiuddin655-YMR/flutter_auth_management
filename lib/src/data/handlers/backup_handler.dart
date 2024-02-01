import 'package:flutter_andomie/core.dart';

import '../../models/auth.dart';
import '../../services/handlers/backup_handler.dart';
import '../../services/repositories/backup_repository.dart';
import '../../services/sources/authorized_data_source.dart';
import '../repositories/backup_repository.dart';

class BackupHandlerImpl<T extends Auth> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl({
    AuthorizedDataSource<T>? source,
    LocalDatabase? database,
  }) : repository = BackupRepositoryImpl<T>(source: source, database: database);

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<T?> get cache => repository.cache.onError((_, __) => null);

  @override
  Future<bool> set(T? data) async {
    if (data == null) return false;
    return update(data.id, data.source);
  }

  @override
  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return repository.set(data ?? value).onError((_, __) => false);
    });
  }

  Map<String, dynamic> _updates(Map<String, dynamic> data) {
    final mData = <String, dynamic>{};
    data.forEach((key, value) {
      if (key.isNotEmpty && value != null && value != '') {
        mData.putIfAbsent(key, () => value);
      }
    });
    return mData;
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> data) async {
    final current = _updates(data);
    if (current.isEmpty) return false;
    try {
      return onFetchUser(id).then((value) {
        if (value != null) {
          return onUpdateUser(id, current).then((_) {
            final updates = value.source;
            updates.addAll(current);
            final user = build(updates);
            return repository.set(user);
          });
        } else {
          final user = build(current);
          return onCreateUser(user).then((_) {
            return repository.set(user);
          });
        }
      });
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clear() {
    return repository.clear().onError((_, __) => false);
  }

  @override
  Future<T?> onFetchUser(String id) {
    return repository.onFetchUser(id).onError((_, __) => null);
  }

  @override
  Future<void> onCreateUser(T data) {
    return repository.onCreateUser(data).onError((_, __) => null);
  }

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    return repository.onUpdateUser(id, data).onError((_, __) => null);
  }

  @override
  Future<void> onDeleteUser(String id) {
    return repository.onDeleteUser(id).onError((_, __) => null);
  }

  @override
  T build(Map<String, dynamic> source) => repository.build(source);
}
