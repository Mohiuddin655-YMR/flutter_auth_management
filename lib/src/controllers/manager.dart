part of 'controllers.dart';

typedef AuthServiceStatus = void Function(AuthResponse response);

class AuthManager {
  AuthManager._();

  AuthProvider? provider;

  final _auth = StreamController<Authorizer?>();

  static Stream<Authorizer?> get auth => _i._auth.stream;

  static AuthManager? _proxy;

  static AuthManager get _i => _proxy ??= AuthManager._();

  static void init(BuildContext context) {
    _i.provider = context.findAuthProvider();
  }

  static void close() => _i._auth.close();

  static AuthResponse emit(AuthResponse value) {
    try {
      _i.provider?.notify(value);
      if (value.isAuthenticated || value.isUnauthenticated) {
        _i._auth.add(value.data);
      }
    } catch (_) {
      throw UnimplementedError("Auth provider not implemented!");
    }
    return value;
  }

  static Authorizer? get data => state?.data;

  static AuthResponse? get state => _i.provider?.notifier.value;
}
