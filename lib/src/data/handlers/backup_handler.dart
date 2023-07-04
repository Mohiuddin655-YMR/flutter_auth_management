part of 'handlers.dart';

class BackupHandlerImpl<T extends Authenticator> extends BackupHandler<T> {
  final BackupRepository<T> repository;

  BackupHandlerImpl({
    String? key,
    BackupDataSource<T>? source,
    SharedPreferences? preferences,
    ConnectivityProvider? connectivity,
  }) : repository = BackupRepositoryImpl<T>(
          key: key,
          source: source,
          preferences: preferences,
          connectivity: connectivity,
        );

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<bool> remove(String? id) => repository.remove(id);

  @override
  Future<T> getCache(String? id) => repository.get(id);

  @override
  Future<bool> setCache(T data) => repository.set(data);

  @override
  Future<void> clearCache() => repository.clearCache();
}
