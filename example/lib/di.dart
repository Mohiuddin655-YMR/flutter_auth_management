import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController>(() {
    return AuthController(
      backup: UserBackupSource(locator()),
    );
  });

  // for remotely user handle
  locator.registerFactory<RemoteDataHandler<User>>(() {
    return RemoteDataHandlerImpl<User>.fromSource(
      source: UserDataSource(),
    );
  });

  await locator.allReady();
}

class User extends Data {
  final String? email;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? username;
  final String? _provider;

  bool get isCurrentUid => id == AuthHelper.uid;

  AuthProvider get provider => AuthProvider.from(_provider);

  User({
    super.id,
    super.timeMills,
    this.email,
    this.name,
    this.password,
    this.phone,
    this.photo,
    String? provider,
    this.username,
  }) : _provider = provider;

  User copy({
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
    return User(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? _provider,
      username: username ?? this.username,
    );
  }

  factory User.from(Object? source) {
    return User(
      id: Data.autoId(source),
      timeMills: Data.autoTimeMills(source),
      email: Data.value<String>("email", source),
      name: Data.value<String>("name", source),
      password: Data.value<String>("password", source),
      phone: Data.value<String>("phone", source),
      photo: Data.value<String>("photo", source),
      provider: Data.value<String>("provider", source),
      username: Data.value<String>("username", source),
    );
  }

  factory User.fromAuth(Auth user) {
    return User(
      id: user.id,
      timeMills: user.timeMills,
      email: user.email,
      name: user.name,
      password: user.password,
      phone: user.phone,
      photo: user.photo,
      provider: user.provider.name,
      username: user.username,
    );
  }

  @override
  Map<String, dynamic> get source {
    return {
      "id": id,
      "time_mills": timeMills,
      "email": email,
      "name": name,
      "password": password,
      "phone": phone,
      "photo": photo,
      "provider": _provider,
      "username": username,
    };
  }
}

class UserDataSource extends FireStoreDataSourceImpl<User> {
  UserDataSource({
    super.path = "auth_users",
  });

  @override
  User build(source) {
    return User.from(source);
  }
}

class UserBackupSource extends BackupSourceImpl {
  final RemoteDataHandler<User> handler;

  UserBackupSource(this.handler);

  @override
  Future<void> onCreated(Auth data) => handler.insert(User.fromAuth(data));

  @override
  Future<void> onDeleted(String id) => handler.delete(id);
}
