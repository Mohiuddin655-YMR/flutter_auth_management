part of 'repositories.dart';

abstract class BackupRepository<T extends Authenticator> {
  final ConnectivityProvider connectivity;

  BackupRepository({
    ConnectivityProvider? connectivity,
  }) : connectivity = connectivity ?? ConnectivityProvider.I;

  Future<bool> get isConnected async => await connectivity.isConnected;

  Future<bool> get isDisconnected async => !(await isConnected);

  String? get uid => user?.uid;

  User? get user => FirebaseAuth.instance.currentUser;

  Future<T> get(String? id);

  Future<bool> set(T data);

  Future<bool> remove(String? id);

  Future<void> clearCache() async {}
}
