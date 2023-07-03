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
  Future<Response<T>> get() async {
    if (isRemotely) {
      if (await isConnected) {
        return source!.get();
      } else {
        return Response<T>().withStatus(Status.networkError);
      }
    } else {
      return _.get();
    }
  }

  @override
  Future<Response<T>> set(T data) async {
    if (isRemotely) {
      if (await isConnected) {
        return source!.set(data);
      } else {
        return Response<T>().withStatus(Status.networkError);
      }
    } else {
      return _.set(data);
    }
  }

  @override
  Future<Response<T>> delete() async {
    if (isRemotely) {
      if (await isConnected) {
        await _.clear();
        return source!.delete();
      } else {
        return Response<T>().withStatus(Status.networkError);
      }
    } else {
      return _.clear();
    }
  }

  @override
  Future<Response<T>> clear() async {
    if (isRemotely) {
      if (await isConnected) {
        await _.clear();
        return source!.clear();
      } else {
        return Response<T>().withStatus(Status.networkError);
      }
    } else {
      return _.clear();
    }
  }
}
