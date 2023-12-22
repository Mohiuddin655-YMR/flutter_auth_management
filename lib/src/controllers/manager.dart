part of 'controllers.dart';

typedef AuthServiceStatus = void Function(AuthResponse response);

class AuthManager {
  AuthManager._();

  Auth? auth;
  AuthProvider? provider;

  static AuthManager? _proxy;

  static AuthManager get _i => _proxy ??= AuthManager._();

  static void init(BuildContext context) {
    _i.provider = context.findAuthProvider();
  }

  static AuthResponse emit(AuthResponse value) {
    try {
      _i.auth = value.data;
      _i.provider?.notify(value);
    } catch (_) {
      throw UnimplementedError("Auth provider not implemented!");
    }
    return value;
  }

  static Auth? get data => _i.auth ?? state?.data;

  static AuthResponse? get state => _i.provider?.notifier.value;
}
