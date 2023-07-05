part of 'responses.dart';

class AuthResponse<T extends Auth> {
  final bool? _initial;
  final bool? _loading;
  final bool? _authenticated;
  final bool? _unauthenticated;
  final bool? _failure;
  final String? _message;
  final String? _error;
  final T? data;
  final AuthProvider? _provider;

  factory AuthResponse.initial() => const AuthResponse._(initial: true);

  factory AuthResponse.loading([
    AuthProvider? provider,
    String? message,
  ]) {
    return AuthResponse._(loading: true, provider: provider, message: message);
  }

  factory AuthResponse.authenticated(T? data, [String? message]) {
    return AuthResponse._(
      authenticated: true,
      data: data,
      message: message,
    );
  }

  factory AuthResponse.unauthenticated([String? message]) {
    return AuthResponse._(
      unauthenticated: true,
      message: message,
    );
  }

  factory AuthResponse.failure(dynamic message) {
    return AuthResponse._(
      failure: true,
      error: message != null ? "$message" : null,
    );
  }

  const AuthResponse._({
    this.data,
    bool? initial,
    bool? loading,
    bool? authenticated,
    bool? unauthenticated,
    bool? failure,
    String? error,
    String? message,
    AuthProvider? provider,
  })  : _initial = initial,
        _loading = loading,
        _authenticated = authenticated,
        _unauthenticated = unauthenticated,
        _failure = failure,
        _error = error,
        _message = message,
        _provider = provider;

  bool get isInitial => _initial ?? false;

  bool get isLoading => _loading ?? false;

  bool get isAuthenticated => _authenticated ?? false;

  bool get isUnauthenticated => _unauthenticated ?? false;

  bool get isFailure => _failure ?? false;

  bool get isError => error.isNotEmpty;

  bool get isMessage => message.isNotEmpty;

  bool isCurrentProvider(AuthProvider value) => provider == value;

  String get error => _error ?? "";

  String get message => _message ?? "";

  AuthProvider get provider => _provider ?? AuthProvider.email;

  Map<String, dynamic> get source {
    return {
      "isInitial": isInitial,
      "isLoading": isLoading,
      "isAuthenticated": isAuthenticated,
      "isUnauthenticated": isUnauthenticated,
      "isFailure": isFailure,
      "isError": isError,
      "error": _error,
      "message": _message,
      "data": data,
    };
  }

  String get beautify =>
      toString().replaceAll(",", "\n").replaceAll("{", "").replaceAll("}", "");

  @override
  String toString() {
    return source.toString();
  }
}

enum AuthType {
  email,
  google,
  unauthenticated,
}
