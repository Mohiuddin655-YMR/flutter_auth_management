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
    return update(data.source);
  }

  @override
  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return repository.set(data ?? value).onError((_, __) => false);
    });
  }

  Map<String, dynamic> _filter(Map<String, dynamic> data) {
    final x = <String, dynamic>{};
    data.forEach((key, value) {
      if (key.isEmpty || value == null || value == "") return;
      x.putIfAbsent(key, () => value);
    });
    return x;
  }

  Map<String, dynamic> _merge({
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) {
    Map<String, dynamic> result = {};
    oldData.forEach((key, value) {
      result[key] = value ?? newData[key];
    });
    newData.forEach((key, value) {
      if (!oldData.containsKey(key)) {
        result[key] = value;
      }
    });

    return result;
  }

  @override
  Future<bool> update(
    Map<String, dynamic> data, {
    bool forUpdate = false,
  }) async {
    if (data.isEmpty) return false;
    try {
      if (forUpdate) {
        return cache.then((local) {
          if (local == null || local.id.isEmpty) return false;
          final filters = _filter(data);
          if (filters.isEmpty) return false;
          return onUpdateUser(local.id, filters).then((_) {
            return onFetchUser(local.id).then((value) {
              return repository.set(value);
            });
          });
        });
      } else {
        final user = build(data);
        return onFetchUser(user.id).then((remote) {
          if (remote != null) {
            final merge = _merge(newData: data, oldData: remote.source);
            return onUpdateUser(user.id, merge).then((_) {
              return onFetchUser(user.id).then((value) {
                return repository.set(value);
              });
            });
          } else {
            return onCreateUser(user).then((_) {
              return repository.set(user);
            });
          }
        });
      }
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
