part of 'core.dart';

typedef AuthServiceStatus = void Function(AuthResponse response);

class AuthManager {
  AuthManager._();

  AuthProvider? provider;

  static AuthManager? _proxy;

  static AuthManager get _i => _proxy ??= AuthManager._();

  static void init(BuildContext context) {
    _i.provider = context.findAuthProvider();
  }

  static AuthResponse emit(AuthResponse value) {
    try {
      _i.provider?.notify(value);
    } catch (_) {
      throw UnimplementedError("Auth provider not implemented!");
    }
    return value;
  }

  static Auth? get data => state?.data;

  static AuthResponse? get state => _i.provider?.notifier.value;

  static Future<Auth?> get auth {
    final controller = _i.provider?.controller;
    if (controller != null) {
      return controller.auth;
    } else {
      return Future.value(null);
    }
  }

  static Stream<Auth?> get liveAuth {
    final controller = _i.provider?.controller;
    if (controller != null) {
      return controller.liveAuth;
    } else {
      return Stream.value(null);
    }
  }
}
