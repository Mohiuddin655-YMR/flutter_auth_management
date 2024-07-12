enum AuthState {
  guest,
  authenticated,
  unauthenticated,
  unauthorized;

  factory AuthState.from(String? source) {
    if (source == guest.name) {
      return AuthState.guest;
    } else if (source == authenticated.name) {
      return AuthState.authenticated;
    } else if (source == unauthenticated.name) {
      return AuthState.unauthenticated;
    } else {
      return AuthState.unauthorized;
    }
  }

  bool get isGuest => this == AuthState.guest;

  bool get isAuthenticated => this == AuthState.authenticated;

  bool get isUnauthenticated => this == AuthState.unauthenticated;

  bool get isUnauthorized => this == AuthState.unauthorized;
}
