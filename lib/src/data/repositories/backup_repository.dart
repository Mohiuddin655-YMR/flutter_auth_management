import '../../models/auth.dart';
import '../../services/repositories/backup_repository.dart';
import '../../services/sources/authorized_data_source.dart';

class BackupRepositoryImpl<T extends Auth> extends BackupRepository<T> {
  final AuthorizedDataSource<T> source;

  BackupRepositoryImpl(this.source);

  @override
  Future<T?> get cache => source.cache;

  @override
  Future<bool> set(T? data) => source.set(data);

  @override
  Future<bool> update(Map<String, dynamic> data) => source.update(data);

  @override
  Future<bool> clear() => source.clear();

  @override
  Future<T?> onFetchUser(String id) => source.onFetchUser(id);

  @override
  Future<void> onCreateUser(T data) => source.onCreateUser(data);

  @override
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    return source.onUpdateUser(id, data);
  }

  @override
  Future<void> onDeleteUser(String id) => source.onDeleteUser(id);

  @override
  T build(Map<String, dynamic> source) => this.source.build(source);
}
