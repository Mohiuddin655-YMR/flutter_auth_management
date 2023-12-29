part of 'responses.dart';

class AuthResponse {
  final bool? _initial;
  final bool? _loading;
  final bool? _authenticated;
  final bool? _unauthenticated;
  final bool? _failure;
  final String? _message;
  final String? _error;
  final Authorizer? data;
  final AuthType? _provider;

  const AuthResponse.initial() : this._(initial: true);

  const AuthResponse.loading([AuthType? provider, String? message])
      : this._(loading: true, provider: provider, message: message);

  const AuthResponse.authenticated(Authorizer? data, [String? message])
      : this._(authenticated: true, data: data, message: message);

  const AuthResponse.unauthenticated([String? message])
      : this._(unauthenticated: true, message: message);

  const AuthResponse.failure(dynamic message)
      : this._(failure: true, error: message != null ? "$message" : null);

  const AuthResponse.rollback(Authorizer? data, [String? message])
      : this._(data: data, message: message);

  const AuthResponse._({
    this.data,
    bool? initial,
    bool? loading,
    bool? authenticated,
    bool? unauthenticated,
    bool? failure,
    String? error,
    String? message,
    AuthType? provider,
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

  bool isCurrentProvider(AuthType value) => provider == value;

  String get error => _error ?? "";

  String get message => _message ?? "";

  AuthType get provider => _provider ?? AuthType.email;

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

  @override
  String toString() => "AuthResponse($source)";
}

class Authorizer extends Entity {
  final bool biometric;
  final bool loggedIn;
  final String? accessToken;
  final String? idToken;
  final String? email;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? username;
  final String? _provider;

  bool get isCurrentUid => id == AuthHelper.uid;

  AuthType get provider => AuthType.from(_provider);

  Authorizer({
    super.id,
    super.timeMills,
    this.biometric = false,
    this.loggedIn = false,
    this.accessToken,
    this.idToken,
    this.email,
    this.name,
    this.password,
    this.phone,
    this.photo,
    String? provider,
    this.username,
  }) : _provider = provider;

  Authorizer copy({
    String? id,
    int? timeMills,
    bool? biometric,
    bool? loggedIn,
    String? accessToken,
    String? idToken,
    String? email,
    String? name,
    String? password,
    String? phone,
    String? photo,
    String? provider,
    String? username,
  }) {
    return Authorizer(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      biometric: biometric ?? this.biometric,
      loggedIn: loggedIn ?? this.loggedIn,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? _provider,
      username: username ?? this.username,
    );
  }

  factory Authorizer.from(Object? source) {
    return Authorizer(
      id: source.entityId,
      timeMills: source.entityTimeMills,
      biometric: Entity.value<bool>("biometric", source) ?? false,
      loggedIn: Entity.value<bool>("logged_in", source) ?? false,
      accessToken: Entity.value<String>("access_token", source),
      idToken: Entity.value<String>("id_token", source),
      email: Entity.value<String>("email", source),
      name: Entity.value<String>("name", source),
      password: Entity.value<String>("password", source),
      phone: Entity.value<String>("phone", source),
      photo: Entity.value<String>("photo", source),
      provider: Entity.value<String>("provider", source),
      username: Entity.value<String>("username", source),
    );
  }

  factory Authorizer.fromUser(User? user) {
    return Authorizer(
      id: user?.uid,
      email: user?.email,
      name: user?.displayName,
      phone: user?.phoneNumber,
      photo: user?.photoURL,
      loggedIn: user != null,
    );
  }

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      "biometric": biometric,
      "logged_in": loggedIn,
      "access_token": accessToken,
      "id_token": idToken,
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

enum AuthType {
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

  factory AuthType.from(String? source) {
    if (source == apple.name) {
      return AuthType.apple;
    } else if (source == biometric.name) {
      return AuthType.biometric;
    } else if (source == email.name) {
      return AuthType.email;
    } else if (source == facebook.name) {
      return AuthType.facebook;
    } else if (source == github.name) {
      return AuthType.github;
    } else if (source == google.name) {
      return AuthType.google;
    } else if (source == phone.name) {
      return AuthType.phone;
    } else if (source == twitter.name) {
      return AuthType.twitter;
    } else if (source == username.name) {
      return AuthType.username;
    } else {
      return AuthType.custom;
    }
  }

  bool get isApple => this == AuthType.apple;

  bool get isBiometric => this == AuthType.biometric;

  bool get isEmail => this == AuthType.email;

  bool get isFacebook => this == AuthType.facebook;

  bool get isGithub => this == AuthType.github;

  bool get isGoogle => this == AuthType.google;

  bool get isPhone => this == AuthType.phone;

  bool get isTwitter => this == AuthType.twitter;

  bool get isUsername => this == AuthType.username;

  bool get isCustom => this == AuthType.custom;
}
