part of 'handlers.dart';

abstract class BackupHandler<T extends Authenticator> {
  Future<Response<T>> get();

  Future<Response<T>> set(T data);

  Future<Response<T>> delete();

  Future<Response<T>> clear();
}
