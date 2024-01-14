part of 'handlers.dart';

class BackupHandlerImpl<T extends Auth> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl({
    BackupDataSource<T>? source,
    LocalDatabase? database,
  }) : repository = BackupRepositoryImpl<T>(source: source, database: database);

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<T?> get cache => repository.cache;

  @override
  Future<bool> set(T? data) {
    return repository.set(data).then((value) {
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
  Future<bool> update(String id, Map<String, dynamic> data) {
    return repository.update(data).then((value) {
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
  Future<bool> clear() => repository.clear();

  @override
  Future<T?> onFetchUser(String id) => repository.onFetchUser(id);

  @override
  Future<void> onCreateUser(T data) => repository.onCreateUser(data);

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    return repository.onUpdateUser(id, data);
  }

  @override
  Future<void> onDeleteUser(String id) => repository.onDeleteUser(id);

  @override
  T build(Map<String, dynamic> source) => repository.build(source);
}
