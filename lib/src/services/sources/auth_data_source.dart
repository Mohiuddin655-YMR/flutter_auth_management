part of 'sources.dart';

abstract class AuthDataSource<T extends Authenticator> {
  AuthDataSource({
    SharedPreferences? preferences,
  }) : _db = preferences;

  SharedPreferences? _db;

  Future<SharedPreferences> get preferences async =>
      _db ??= await SharedPreferences.getInstance();

  Future<Response<T>> create(T data);

  Future<Response<T>> delete(T data);

  Future<Response<T>> load();

  T build(dynamic source);
}
