part of 'handlers.dart';

class BackupHandlerImpl<T extends Auth> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl({
    BackupSource<T>? source,
    SharedPreferences? preferences,
  }) : repository =
            BackupRepositoryImpl<T>(source: source, preferences: preferences);

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<T> getCache([String? id]) => repository.getCache();

  @override
  Future<bool> setCache(T data) async {
    try {
      await onCreated(data);
    } catch (_) {}
    return repository.setCache(data);
  }

  @override
  Future<bool> removeCache([String? id]) => repository.removeCache();

  @override
  Future<void> onCreated(T data) => repository.onCreated(data);

  @override
  Future<void> onDeleted(String id) => repository.onDeleted(id);
}
