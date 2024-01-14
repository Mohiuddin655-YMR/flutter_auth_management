part of 'core.dart';

/// to find observer and notify current state
extension AuthContextExtension on BuildContext {
  /// to find
  AuthProvider<T>? findAuthProvider<T extends Auth>() => AuthProvider.of<T>(this);

  AuthController<T> findAuthController<T extends Auth>([AuthController<T>? secondary]) {
    return AuthProvider.controllerOf<T>(this, secondary);
  }

  /// to notify state
  void notifyState<T extends Auth>(AuthResponse<T> data) {
    var observer = findAuthProvider();
    if (observer != null) {
      observer.notify(data);
    }
  }
}

extension AuthFutureExtension<T extends Auth> on Future<AuthResponse<T>> {
  Future<AuthResponse<T>> onStatus(void Function(bool loading) callback) async {
    callback(true);
    final data = await this;
    callback(false);
    return data;
  }
}
