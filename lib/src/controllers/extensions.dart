part of 'controllers.dart';

/// to find observer and notify current state
extension AuthContextExtension on BuildContext {
  /// to find
  AuthProvider? findAuthProvider() => AuthProvider.of(this);

  AuthController findAuthController([AuthController? secondary]) {
    return AuthProvider.controllerOf(this, secondary);
  }

  /// to notify state
  void notifyState(AuthResponse data) {
    var observer = findAuthProvider();
    if (observer != null) {
      observer.notify(data);
    }
  }
}

extension AuthFutureExtension on Future<AuthResponse> {
  Future<AuthResponse> onStatus(void Function(bool loading) callback) async {
    callback(true);
    final data = await this;
    callback(false);
    return data;
  }
}
