import '../../models/auth.dart';
import '../../services/handlers/backup_handler.dart';
import '../../services/repositories/backup_repository.dart';
import '../../services/sources/authorized_data_source.dart';
import '../repositories/backup_repository.dart';

class BackupHandlerImpl<T extends Auth> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl(AuthorizedDataSource<T> source)
      : repository = BackupRepositoryImpl<T>(source);

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
      return cache.then((local) async {
        if (local != null && local.isLoggedIn && local.id.isNotEmpty) {
          await onUpdateUser(local.id, data);
          return onFetchUser(local.id).then((value) {
            if (value != null) {
              return repository.set(value);
            } else {
              return repository.update(data);
            }
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
  Future<bool> save({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;
    try {
      if (cacheUpdateMode) {
        return repository.update(updates);
      } else {
        final remote = await onFetchUser(id);
        if (remote != null) {
          await onUpdateUser(id, updates);
          Map<String, dynamic> current = Map.from(remote.source);
          current.addAll(updates);
          return repository.set(build(current));
        } else {
          final cachedUser = await cache;
          if (cachedUser == null) {
            final user = build(initials);
            await onCreateUser(user);
            return repository.set(user);
          } else {
            return repository.update(updates);
          }
        }
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clear() {
    return repository.clear();
  }

  @override
  Future<T?> onFetchUser(String id) => repository.onFetchUser(id);

  @override
  Future<void> onCreateUser(T data) {
    return repository.onCreateUser(data);
  }

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    return repository.onUpdateUser(id, data);
  }

  @override
  Future<void> onDeleteUser(String id) {
    return repository.onDeleteUser(id);
  }

  @override
  T build(Map<String, dynamic> source) => repository.build(source);
}
