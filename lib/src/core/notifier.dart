part of 'core.dart';

/// to notify current state
class AuthNotifier<T extends Auth> extends ValueNotifier<AuthResponse<T>> {
  AuthNotifier(super.value);

  void setValue(AuthResponse<T> value) {
    this.value = value;
    notifyListeners();
  }
}
