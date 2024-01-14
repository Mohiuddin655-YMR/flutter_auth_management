# flutter_auth_management

Collection of service with advanced style and controlling system.

## Biometric Login

# Activity Changes:

import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
// ...
}

# Permissions

<manifest xmlns:android="http://schemas.android.com/apk/res/android"
package="com.example.app">
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<manifest>

## Auth provider instance

### Import the library

```dart
import 'package:auth_management/core.dart';
```

```dart
class UserKeys extends AuthKeys {
  final address = "address";
  final contact = "contact";

  const UserKeys._();

  static UserKeys? _i;

  static UserKeys get i => _i ??= const UserKeys._();
}

class UserModel extends Auth<UserKeys> {
  final Address? _address;
  final Contact? _contact;

  Address get address => _address ?? Address();

  Contact get contact => _contact ?? Contact();

  UserModel({
    super.id,
    super.timeMills,
    super.accessToken,
    super.biometric,
    super.email,
    super.extra,
    super.idToken,
    super.loggedIn,
    super.name,
    super.password,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    Address? address,
    Contact? contact,
  })  : _address = address,
        _contact = contact;

  factory UserModel.from(Object? source) {
    final key = UserKeys.i;
    final root = Auth.from(source);
    return UserModel(
      /// ROOT PROPERTIES
      id: root.id,
      timeMills: root.timeMills,
      accessToken: root.accessToken,
      biometric: root.biometric,
      email: root.email,
      extra: root.extra,
      idToken: root.idToken,
      loggedIn: root.loggedIn,
      name: root.name,
      password: root.password,
      phone: root.phone,
      photo: root.photo,
      provider: root.provider,
      username: root.username,

      /// CHILD PROPERTIES
      address: source.entityObject(key.address, Address.from),
      contact: source.entityObject(key.address, Contact.from),
    );
  }

  @override
  UserModel copy({
    String? id,
    int? timeMills,
    String? accessToken,
    bool? biometric,
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
    return UserModel(
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

  @override
  UserKeys makeKey() => UserKeys.i;

  @override
  Map<String, dynamic> get source {
    return super.source.attach({
      key.address: _address?.source,
      key.contact: _contact?.source,
    });
  }
}

class Address extends Entity {
  Address();

  factory Address.from(Object? source) {
    return Address();
  }
}

class Contact extends Entity {
  Contact();

  factory Contact.from(Object? source) {
    return Contact();
  }
}
```

### Create user backup instance

```dart
class UserBackup extends BackupDataSourceImpl {
  @override
  Future<void> onCreated(Auth data) async {
    // Store authorized user data in remote server
    log("Authorized user data : $data");
  }

  @override
  Future<void> onDeleted(String id) async {
    // Clear unauthorized user data from remote server
    log("Unauthorized user id : $id");
  }
}
```

### Main instance

```dart
class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      controller: AuthController(backup: UserBackup()),
      child: MaterialApp(
        title: 'Auth Management',
        home: AuthObserver(
          listener: (context, value) {
            if (value.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value.error)),
              );
            }
            if (value.isMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value.message)),
              );
            }
          },
          builder: (context, value) {
            if (value.isAuthenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
```

### Create Auth screen
```dart
import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthController controller;
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller = AuthProvider.controllerOf(context);
    });
    super.initState();
  }

  void login() async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signInByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(indicatorVisible);
  }

  void register() async {
    final email = etEmail.text;
    final password = etPassword.text;
    controller
        .signUpByEmail(EmailAuthenticator(email: email, password: password))
        .onStatus(indicatorVisible);
  }

  void indicatorVisible(bool value) {
    setState(() => loading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Builder(builder: (context) {
        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              TextField(
                controller: etEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: etPassword,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    register();
                  },
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

### Create Home screen
```dart
import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthController controller;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller = AuthProvider.controllerOf(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Home",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.signOut();
                  },
                  child: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```