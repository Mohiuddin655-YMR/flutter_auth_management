import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_andomie/core.dart';

import '../utils/auth_helper.dart';
import 'auth_providers.dart';
import 'biometric_status.dart';

/// ## Create an authorized key class for User:
///
/// ```dart
/// class UserKeys extends AuthKeys {
///   final address = "address";
///   final contact = "contact";
///
///   const UserKeys._();
///
///   static UserKeys? _i;
///
///   static UserKeys get i => _i ??= const UserKeys._();
/// }
///```
class AuthKeys extends EntityKey {
  static const key = "__uid__";

  final String accessToken;
  final String biometric;
  final String email;
  final String extra;
  final String idToken;
  final String loggedIn;
  final String name;
  final String password;
  final String phone;
  final String photo;
  final String provider;
  final String username;

  const AuthKeys({
    super.id,
    super.timeMills,
    this.accessToken = "access_token",
    this.biometric = "biometric",
    this.email = "email",
    this.extra = "extra",
    this.idToken = "id_token",
    this.loggedIn = "logged_in",
    this.name = "name",
    this.password = "password",
    this.phone = "phone",
    this.photo = "photo",
    this.provider = "provider",
    this.username = "username",
  });

  static AuthKeys? _i;

  static AuthKeys get i => _i ??= const AuthKeys();
}

/// ## Create an authorized model class for User:
///
/// ```dart
/// class UserKeys extends AuthKeys {
///   final address = "address";
///   final contact = "contact";
///
///   const UserKeys._();
///
///   static UserKeys? _i;
///
///   static UserKeys get i => _i ??= const UserKeys._();
/// }
///
/// class UserModel extends Auth<UserKeys> {
///   final Address? _address;
///   final Contact? _contact;
///
///   Address get address => _address ?? Address();
///
///   Contact get contact => _contact ?? Contact();
///
///   UserModel({
///     super.id,
///     super.timeMills,
///     super.accessToken,
///     super.biometric,
///     super.email,
///     super.extra,
///     super.idToken,
///     super.loggedIn,
///     super.name,
///     super.password,
///     super.phone,
///     super.photo,
///     super.provider,
///     super.username,
///     Address? address,
///     Contact? contact,
///   })  : _address = address,
///         _contact = contact;
///
///   factory UserModel.from(Object? source) {
///     final key = UserKeys.i;
///     final root = Auth.from(source);
///     return UserModel(
///       // ROOT PROPERTIES
///       id: root.id,
///       timeMills: root.timeMills,
///       accessToken: root.accessToken,
///       biometric: root.biometric,
///       email: root.email,
///       extra: root.extra,
///       idToken: root.idToken,
///       loggedIn: root.loggedIn,
///       name: root.name,
///       password: root.password,
///       phone: root.phone,
///       photo: root.photo,
///       provider: root.provider,
///       username: root.username,
///
///       // CHILD PROPERTIES
///       address: source.entityObject(key.address, Address.from),
///       contact: source.entityObject(key.address, Contact.from),
///     );
///   }
///
///   @override
///   UserModel copy({
///     String? id,
///     int? timeMills,
///     String? accessToken,
///     String? biometric,
///     String? email,
///     Map<String, dynamic>? extra,
///     String? idToken,
///     bool? loggedIn,
///     String? name,
///     String? password,
///     String? phone,
///     String? photo,
///     String? provider,
///     String? username,
///     Address? address,
///     Contact? contact,
///   }) {
///     return UserModel(
///       id: id ?? this.id,
///       timeMills: timeMills ?? this.timeMills,
///       accessToken: accessToken ?? this.accessToken,
///       biometric: biometric ?? this.biometric,
///       email: email ?? this.email,
///       extra: extra ?? this.extra,
///       idToken: idToken ?? this.idToken,
///       loggedIn: loggedIn ?? this.loggedIn,
///       name: name ?? this.name,
///       password: password ?? this.password,
///       phone: phone ?? this.phone,
///       photo: photo ?? this.photo,
///       provider: provider ?? this.provider,
///       username: username ?? this.username,
///       address: address ?? this.address,
///       contact: contact ?? this.contact,
///     );
///   }
///
///   @override
///   UserKeys makeKey() => UserKeys.i;
///
///   @override
///   Map<String, dynamic> get source {
///     return super.source.attach({
///       key.address: _address?.source,
///       key.contact: _contact?.source,
///     });
///   }
/// }
///
/// class Address extends Entity {
///   Address();
///
///   factory Address.from(Object? source) {
///     return Address();
///   }
/// }
///
/// class Contact extends Entity {
///   Contact();
///
///   factory Contact.from(Object? source) {
///     return Contact();
///   }
/// }
/// ```

class Auth<Key extends AuthKeys> extends Entity<Key> {
  final String? accessToken;
  final String? biometric;
  final String? idToken;
  final String? email;
  final Map<String, dynamic>? extra;
  final bool? loggedIn;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? provider;
  final String? username;

  bool get isLoggedIn => loggedIn ?? false;

  bool get isCurrentUid => id == AuthHelper.uid;

  bool get isBiometric => mBiometric.isActivated;

  BiometricStatus get mBiometric => BiometricStatus.from(biometric);

  AuthProviders get mProvider => AuthProviders.from(provider);

  Auth({
    super.id,
    super.timeMills,
    this.accessToken,
    this.biometric,
    this.email,
    this.extra,
    this.idToken,
    this.loggedIn,
    this.name,
    this.password,
    this.phone,
    this.photo,
    this.provider,
    this.username,
  });

  Auth copy({
    String? id,
    int? timeMills,
    String? accessToken,
    String? biometric,
    String? email,
    Map<String, dynamic>? extra,
    String? idToken,
    bool? loggedIn,
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
      biometric: biometric ?? this.biometric,
      email: email ?? this.email,
      extra: extra ?? this.extra,
      idToken: idToken ?? this.idToken,
      loggedIn: loggedIn ?? this.loggedIn,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? this.provider,
      username: username ?? this.username,
    );
  }

  factory Auth.from(Object? source) {
    final key = AuthKeys.i;
    return Auth(
      id: source.entityValue(key.id),
      timeMills: source.entityValue(key.timeMills),
      accessToken: source.entityValue(key.accessToken),
      biometric: source.entityValue(key.biometric),
      loggedIn: source.entityValue(key.loggedIn),
      idToken: source.entityValue(key.idToken),
      email: source.entityValue(key.email),
      name: source.entityValue(key.name),
      password: source.entityValue(key.password),
      phone: source.entityValue(key.phone),
      photo: source.entityValue(key.photo),
      provider: source.entityValue(key.provider),
      username: source.entityValue(key.username),
      extra: source.entityObject(key.extra, (value) {
        return value is Map<String, dynamic> ? value : {};
      }),
    );
  }

  factory Auth.fromUser(User? user) {
    return Auth(
      id: user?.uid,
      email: user?.email,
      name: user?.displayName,
      phone: user?.phoneNumber,
      photo: user?.photoURL,
      loggedIn: user != null,
      extra: {
        "emailVerified": user?.emailVerified,
        "isAnonymous": user?.isAnonymous,
        "metadata": {
          "creationTime": user?.metadata.creationTime?.millisecondsSinceEpoch,
          "lastSignInTime":
              user?.metadata.lastSignInTime?.millisecondsSinceEpoch,
        },
        "providerData": user?.providerData.map((e) {
          return {
            "displayName": e.displayName,
            "email": e.email,
            "phoneNumber": e.phoneNumber,
            "photoURL": e.photoURL,
            "providerId": e.providerId,
            "uid": e.uid,
          };
        }).toList(),
        "refreshToken": user?.refreshToken,
        "tenantId": user?.tenantId,
      },
    );
  }

  @override
  Key makeKey() {
    try {
      return const AuthKeys() as Key;
    } catch (_) {
      return throw UnimplementedError(
        "You must override makeKey() and return the current key from sub-entity class.",
      );
    }
  }

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      key.accessToken: accessToken,
      key.biometric: biometric,
      key.email: email,
      key.extra: extra,
      key.idToken: idToken,
      key.loggedIn: loggedIn,
      key.name: name,
      key.password: password,
      key.phone: phone,
      key.photo: photo,
      key.provider: provider,
      key.username: username,
    });
  }
}
