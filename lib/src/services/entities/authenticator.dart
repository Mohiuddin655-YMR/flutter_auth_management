part of 'entities.dart';

class Authenticator extends Entity {
  final String? email;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? provider;
  final String? username;

  Authenticator({
    super.id,
    super.timeMills,
    this.email,
    this.name,
    this.password,
    this.phone,
    this.photo,
    this.provider,
    this.username,
  });

  Authenticator copy({
    String? id,
    int? timeMills,
    String? email,
    String? name,
    String? password,
    String? phone,
    String? photo,
    String? provider,
    String? username,
  }) {
    return Authenticator(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? this.provider,
      username: username ?? this.username,
    );
  }

  factory Authenticator.from(Object? source) {
    return Authenticator(
      id: source.entityId,
      timeMills: source.entityTimeMills,
      email: Entity.value<String>("email", source),
      name: Entity.value<String>("name", source),
      password: Entity.value<String>("password", source),
      phone: Entity.value<String>("phone", source),
      photo: Entity.value<String>("photo", source),
      provider: Entity.value<String>("provider", source),
      username: Entity.value<String>("username", source),
    );
  }

  bool get isCurrentUid => id == AuthHelper.uid;

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      "email": email,
      "name": name,
      "password": password,
      "phone": phone,
      "photo": photo,
      "provider": provider,
      "username": username,
    });
  }
}

enum AuthProvider {
  apple,
  biometric,
  custom,
  email,
  facebook,
  github,
  google,
  phone,
  twitter,
  username,
}
