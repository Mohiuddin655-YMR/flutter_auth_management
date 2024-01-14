part of 'models.dart';

enum AuthState {
  none,
  guest,
  authenticated,
  unauthenticated,
  loading;

  factory AuthState.from(String? source) {
    if (source == guest.name) {
      return AuthState.guest;
    } else if (source == authenticated.name) {
      return AuthState.authenticated;
    } else if (source == unauthenticated.name) {
      return AuthState.unauthenticated;
    } else if (source == loading.name) {
      return AuthState.loading;
    } else {
      return AuthState.none;
    }
  }

  bool get isGuest => this == AuthState.guest;

  bool get isAuthenticated => this == AuthState.authenticated;

  bool get isUnauthenticated => this == AuthState.unauthenticated;

  bool get isLoading => this == AuthState.loading;

  bool get isSuccessful => isGuest || isAuthenticated || isUnauthenticated;
}
