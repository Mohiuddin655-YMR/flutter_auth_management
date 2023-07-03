part of 'sources.dart';

abstract class BackupDataSource<T extends Authenticator> {
  BackupDataSource({
    SharedPreferences? preferences,
  }) : _db = preferences;

  SharedPreferences? _db;

  Future<SharedPreferences> get preferences async =>
      _db ??= await SharedPreferences.getInstance();

  Future<Response<T>> set(T data);

  Future<Response<T>> get();

  Future<Response<T>> delete();

  Future<Response<T>> clear();

  T build(dynamic source);
}
