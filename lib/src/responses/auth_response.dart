part of 'responses.dart';

class AuthResponse<T extends Auth> {
  final bool? _initial;
  final bool? _loading;
  final String? _error;
  final String? _message;
  final T? data;
  final AuthActions? _action;
  final AuthProviders? _provider;
  final AuthState? _state;
  final AuthType? _type;

  bool get isInitial => _initial ?? false;

  bool get isLoading => _loading ?? false;

  bool get isError => error.isNotEmpty;

  bool get isMessage => message.isNotEmpty;

  bool get isState => state != AuthState.none;

  String get error => _error ?? "";

  String get message => _message ?? "";

  AuthActions get action => _action ?? AuthActions.none;

  AuthProviders get provider => _provider ?? AuthProviders.email;

  AuthState get state => _state ?? AuthState.none;

  AuthType get type => _type ?? AuthType.none;

  bool isCurrentProvider(AuthProviders value) => provider == value;

  bool isCurrentAction(AuthActions action) {
    return action == this.action;
  }

  const AuthResponse.initial({
    AuthActions action = AuthActions.none,
    dynamic message,
    AuthProviders? provider,
    AuthType? type,
  }) : this._(
          action,
          initial: true,
          message: message,
          provider: provider,
          type: type,
        );

  const AuthResponse.loading(
    AuthActions action, [
    AuthProviders? provider,
    AuthType? type,
  ]) : this._(action, loading: true, provider: provider, type: type);

  const AuthResponse.guest(
    AuthActions action,
    T? data, {
    dynamic message,
    AuthProviders? provider,
    AuthType? type,
  }) : this._(
          action,
          state: AuthState.guest,
          data: data,
          message: message,
          provider: provider,
          type: type,
        );

  const AuthResponse.authenticated(
    AuthActions action,
    T? data, {
    dynamic message,
    AuthProviders? provider,
    AuthType? type,
  }) : this._(
          action,
          state: AuthState.authenticated,
          data: data,
          message: message,
          provider: provider,
          type: type,
        );

  const AuthResponse.unauthenticated(
    AuthActions action, {
    dynamic message,
    AuthProviders? provider,
    AuthType? type,
  }) : this._(
          action,
          state: AuthState.unauthenticated,
          message: message,
          provider: provider,
          type: type,
        );

  const AuthResponse.message(
    AuthActions action,
    dynamic message, {
    AuthProviders? provider,
    AuthType? type,
  }) : this._(action, message: message, provider: provider, type: type);

  const AuthResponse.failure(
    AuthActions action,
    dynamic message, {
    AuthProviders? provider,
    AuthType? type,
  }) : this._(action, error: message, provider: provider, type: type);

  const AuthResponse.rollback(
    AuthActions action,
    T? data, {
    dynamic message,
    AuthProviders? provider,
    AuthType? type,
  }) : this._(
          action,
          data: data,
          message: message,
          provider: provider,
          type: type,
        );

  const AuthResponse._(
    AuthActions action, {
    this.data,
    bool? initial,
    bool? loading,
    dynamic error,
    dynamic message,
    AuthProviders? provider,
    AuthState? state,
    AuthType? type,
  })  : _action = action,
        _initial = initial,
        _loading = loading,
        _error = error != null ? "$error" : null,
        _message = message != null ? "$message" : null,
        _provider = provider,
        _state = state,
        _type = type;

  Map<String, dynamic> get _source {
    return {
      "isInitial": isInitial,
      "isLoading": isLoading,
      "isError": isError,
      "error": _error,
      "message": _message,
      "data": data,
      "provider": _provider,
      "status": _state,
      "type": _type,
    };
  }

  @override
  String toString() => "AuthResponse($_source)";
}
