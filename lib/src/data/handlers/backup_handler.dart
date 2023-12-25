part of 'handlers.dart';

class BackupHandlerImpl extends BackupHandler {
  final BackupRepository repository;

  BackupHandlerImpl({
    BackupDataSource? source,
    LocalDatabase? database,
  }) : repository = BackupRepositoryImpl(source: source, database: database);

  BackupHandlerImpl.fromRepository(this.repository);

  @override
  Future<Authorizer?> getCache([String? id]) => repository.getCache();

  @override
  Future<bool> setCache(Authorizer? data) async {
    if (data != null) {
      try {
        await onCreated(data);
      } catch (_) {}
    }
    return repository.setCache(data);
  }

  @override
  Future<bool> removeCache([String? id]) => repository.removeCache();

  @override
  Future<void> onCreated(Authorizer data) => repository.onCreated(data);

  @override
  Future<void> onDeleted(String id) => repository.onDeleted(id);
}
