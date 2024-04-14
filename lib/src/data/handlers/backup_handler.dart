import 'package:in_app_database/in_app_database.dart';

import '../../models/auth.dart';
import '../../services/handlers/backup_handler.dart';
import '../../services/repositories/backup_repository.dart';
import '../../services/sources/authorized_data_source.dart';
import '../repositories/backup_repository.dart';

class BackupHandlerImpl<T extends Auth> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl({
    AuthorizedDataSource<T>? source,
    InAppDatabase? database,
  }) : repository = BackupRepositoryImpl<T>(source: source, database: database);

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<T?> get cache => repository.cache.onError((_, __) => null);

  @override
  Future<T?> get([bool remotely = false]) {
    return cache.then((value) {
      if (value != null && value.isLoggedIn) {
        if (remotely) {
          return repository.onFetchUser(value.id);
        } else {
          return value;
        }
      } else {
        return null;
      }
    });
  }

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

  @override
  Future<bool> update(Map<String, dynamic> data) async {
    if (data.isEmpty) return false;
    try {
      return cache.then((local) {
        if (local != null && local.isLoggedIn && local.id.isNotEmpty) {
          return onUpdateUser(local.id, data).then((_) {
            return onFetchUser(local.id).then((value) {
              return repository.set(value);
            });
          });
        } else {
          return false;
        }
      });
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> updateAsLocal({
    required String id,
    Map<String, dynamic> creates = const {},
    Map<String, dynamic> updates = const {},
    bool updateMode = false,
  }) async {
    if (id.isEmpty) return false;
    try {
      if (updateMode) {
        if (updates.isNotEmpty) {
          return onUpdateUser(id, updates).then((_) {
            return onFetchUser(id).then((value) {
              return repository.set(value);
            });
          });
        } else {
          return false;
        }
      } else {
        return onFetchUser(id).then((remote) {
          if (remote != null) {
            if (updates.isNotEmpty) {
              return onUpdateUser(id, updates).then((_) {
                return onFetchUser(id).then((value) {
                  return repository.set(value);
                });
              });
            } else {
              return false;
            }
          } else {
            final user = build(creates);
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
