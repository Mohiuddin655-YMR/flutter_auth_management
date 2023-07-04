part of 'repositories.dart';

class BackupRepositoryImpl<T extends Authenticator>
    extends BackupRepository<T> {
  final String? key;
  final BackupDataSource<T> _;
  final BackupDataSource<T>? source;

  BackupRepositoryImpl({
    super.connectivity,
    this.key,
    this.source,
    SharedPreferences? preferences,
  }) : _ = KeepDataSourceImpl<T>(key: key, preferences: preferences);

  bool get isRemotely => source != null;

  @override
  Future<T> get(String? id) async {
    if (isRemotely) {
      if (await isConnected) {
        return source!.getCache(id ?? uid);
      } else {
        return Future.error("Network unavailable!");
      }
    } else {
      return _.getCache(key);
    }
  }

  @override
  Future<bool> set(T data) async {
    if (isRemotely) {
      if (await isConnected) {
        return source!.setCache(data);
      } else {
        return Future.error("Network unavailable!");
      }
    } else {
      return _.setCache(data);
    }
  }

  @override
  Future<bool> remove(String? id) async {
    if (isRemotely) {
      if (await isConnected) {
        await _.removeCache(key);
        return source!.removeCache(id ?? uid);
      } else {
        return Future.error("Network unavailable!");
      }
    } else {
      return _.removeCache(key);
    }
  }

  @override
  Future<void> clearCache() => _.clearCache();
}
