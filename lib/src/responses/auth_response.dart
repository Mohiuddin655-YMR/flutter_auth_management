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

class Auth extends Entity {
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final String? email;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? username;
  final String? _provider;

  bool get isCurrentUid => id == AuthHelper.uid;

  AuthProvider get provider => AuthProvider.from(_provider);

  Auth({
    super.id,
    super.timeMills,
    this.accessToken,
    this.idToken,
    this.refreshToken,
    this.email,
    this.name,
    this.password,
    this.phone,
    this.photo,
    String? provider,
    this.username,
  }) : _provider = provider;

  Auth copy({
    String? id,
    int? timeMills,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    String? email,
    String? name,
    String? password,
    String? phone,
    String? photo,
    String? provider,
    String? username,
  }) {
    return Auth(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? _provider,
      username: username ?? this.username,
    );
  }

  factory Auth.from(Object? source) {
    return Auth(
      id: source.entityId,
      timeMills: source.entityTimeMills,
      accessToken: Entity.value<String>("access_token", source),
      idToken: Entity.value<String>("id_token", source),
      refreshToken: Entity.value<String>("refresh_token", source),
      email: Entity.value<String>("email", source),
      name: Entity.value<String>("name", source),
      password: Entity.value<String>("password", source),
      phone: Entity.value<String>("phone", source),
      photo: Entity.value<String>("photo", source),
      provider: Entity.value<String>("provider", source),
      username: Entity.value<String>("username", source),
    );
  }

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      "access_token": accessToken,
      "id_token": idToken,
      "refresh_token": refreshToken,
      "email": email,
      "name": name,
      "password": password,
      "phone": phone,
      "photo": photo,
      "provider": _provider,
      "username": username,
    });
  }
}

enum AuthProvider {
  apple,
  biometric,
  email,
  facebook,
  github,
  google,
  phone,
  twitter,
  username,
  custom;

  factory AuthProvider.from(String? source) {
    if (source == apple.name) {
      return AuthProvider.apple;
    } else if (source == biometric.name) {
      return AuthProvider.biometric;
    } else if (source == email.name) {
      return AuthProvider.email;
    } else if (source == facebook.name) {
      return AuthProvider.facebook;
    } else if (source == github.name) {
      return AuthProvider.github;
    } else if (source == google.name) {
      return AuthProvider.google;
    } else if (source == phone.name) {
      return AuthProvider.phone;
    } else if (source == twitter.name) {
      return AuthProvider.twitter;
    } else if (source == username.name) {
      return AuthProvider.username;
    } else {
      return AuthProvider.custom;
    }
  }
}

enum AuthType {
  email,
  google,
  unauthenticated,
}

extension AuthProviderExtension on AuthProvider {
  bool get isApple => this == AuthProvider.apple;

  bool get isBiometric => this == AuthProvider.biometric;

  bool get isEmail => this == AuthProvider.email;

  bool get isFacebook => this == AuthProvider.facebook;

  bool get isGithub => this == AuthProvider.github;

  bool get isGoogle => this == AuthProvider.google;

  bool get isPhone => this == AuthProvider.phone;

  bool get isTwitter => this == AuthProvider.twitter;

  bool get isUsername => this == AuthProvider.username;

  bool get isCustom => this == AuthProvider.custom;
}
