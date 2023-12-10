part of 'controllers.dart';

typedef AuthServiceStatus = void Function(AuthResponse response);

class AuthManager {
  AuthManager._();

  Auth? auth;
  AuthProvider? observer;
  AuthServiceStatus? status;

  static AuthManager? _proxy;

  static AuthManager get _i => _proxy ??= AuthManager._();

  static void init(BuildContext context) {
    _i.observer = context.findAuthProvider();
  }

  static void onStatusChange(AuthResponse response) {
    if (_i.status != null) _i.status?.call(response);
  }

  static AuthResponse emit(AuthResponse value) {
    try {
      _i.auth = value.data;
      _i.observer?.notify(value);
    } catch (_) {
      throw UnimplementedError("Auth provider not implemented!");
    }
    return value;
  }

  static void listen(AuthServiceStatus status) {
    _i.status = status;
  }

  static Auth? get data => _i.auth ?? state?.data;

  static AuthResponse? get state => _i.observer?.notifier.value;
}
