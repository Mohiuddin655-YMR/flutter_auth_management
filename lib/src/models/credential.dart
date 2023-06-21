part of 'models.dart';

class Credential {
  final OAuthCredential? credential;
  final String? id;
  final String? email;
  final String? name;
  final String? photo;
  final String? idToken;
  final String? accessToken;

  const Credential({
    this.credential,
    this.id,
    this.email,
    this.name,
    this.photo,
    this.idToken,
    this.accessToken,
  });

  factory Credential.fromMap(Map<String, dynamic> map) {
    String? id = map['id'];
    String? email = map['email'];
    String? name = map['name'];
    String? photo;
    try {
      photo = map['picture']['data']['url'];
    } catch (_) {
      photo = '';
    }
    return Credential(
      id: id,
      email: email,
      name: name,
      photo: photo,
    );
  }

  Credential copy({
    String? id,
    String? name,
    String? email,
    String? photo,
    String? accessToken,
    String? idToken,
    OAuthCredential? credential,
  }) {
    return Credential(
      credential: credential ?? this.credential,
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "photo": photo,
      "accessToken": accessToken,
      "idToken": idToken,
    };
  }
}
