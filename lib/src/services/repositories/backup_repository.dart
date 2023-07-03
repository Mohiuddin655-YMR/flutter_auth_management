part of 'repositories.dart';

abstract class BackupRepository<T extends Authenticator> {
  final ConnectivityProvider connectivity;

  BackupRepository({
    ConnectivityProvider? connectivity,
  }) : connectivity = connectivity ?? ConnectivityProvider.I;

  Future<bool> get isConnected async => await connectivity.isConnected;

  Future<bool> get isDisconnected async => !(await isConnected);

  Future<Response<T>> get();

  Future<Response<T>> set(T data);

  Future<Response<T>> delete();

  Future<Response<T>> clear();
}
