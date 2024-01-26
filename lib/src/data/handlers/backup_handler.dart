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
  Future<bool> set(T? data) {
    return repository.set(data).onError((_, __) => false).then((value) {
      if (data != null && value) {
        try {
          return onFetchUser(data.id).then((value) async {
            if (value != null) {
              return onUpdateUser(data.id, data.source).then((value) => true);
            } else {
              return onCreateUser(data).then((value) => true);
            }
          });
        } catch (_) {
          return true;
        }
      } else {
        return value;
      }
    });
  }

  @override
  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return repository.set(data ?? value).onError((_, __) => false);
    });
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> data) {
    return repository.update(data).onError((_, __) => false).then((value) {
      if (data.isNotEmpty && value) {
        try {
          return onFetchUser(id).then((value) async {
            if (value != null) {
              return onUpdateUser(id, data).then((value) => true);
            } else {
              return onCreateUser(build(data)).then((value) => true);
            }
          });
        } catch (_) {
          return true;
        }
      } else {
        return value;
      }
    });
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
