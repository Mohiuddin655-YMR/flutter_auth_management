part of 'controllers.dart';

/// to notify current state
class AuthNotifier extends ValueNotifier<AuthResponse> {
  AuthNotifier(super.value);

  void setValue(AuthResponse value) {
    this.value = value;
    notifyListeners();
  }
}
