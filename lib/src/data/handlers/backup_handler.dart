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
  Future<Response<T>> get() => repository.get();

  @override
  Future<Response<T>> set(T data) => repository.set(data);

  @override
  Future<Response<T>> delete() => repository.delete();

  @override
  Future<Response<T>> clear() => repository.clear();
}
