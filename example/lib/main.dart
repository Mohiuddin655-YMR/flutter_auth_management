import 'package:auth_management/core.dart';
import 'package:data_management/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> diInit() async {
  locator.registerFactory<AuthController>(() {
    return AuthController(
      backupHandler: BackupHandlerImpl(
        source: UserBackupSource(locator()),
      ),
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: !kIsWeb
        ? null
        : const FirebaseOptions(
            apiKey: "AIzaSyAnDJmmToo0dPGEeAV9J-7bsghSaiByFjU",
            authDomain: "flutter-ui-kits.firebaseapp.com",
            databaseURL: "https://flutter-ui-kits-default-rtdb.firebaseio.com",
            projectId: "flutter-ui-kits",
            storageBucket: "flutter-ui-kits.appspot.com",
            messagingSenderId: "807732577100",
            appId: "1:807732577100:web:ee043c33d35bddeb2945e9",
            measurementId: "G-D2Q97HYEEQ",
          ),
  );
  await diInit();
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: BlocProvider(
              create: (context) => locator<AuthController>(),
              child: const AuthenticationTest(),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthenticationTest extends StatefulWidget {
  const AuthenticationTest({Key? key}) : super(key: key);

  @override
  State<AuthenticationTest> createState() => _AuthenticationTestState();
}

class _AuthenticationTestState extends State<AuthenticationTest> {
  late AuthController controller = context.read<AuthController>();

  late TextEditingController email = TextEditingController();
  late TextEditingController username = TextEditingController();
  late TextEditingController password = TextEditingController();

  @override
  void initState() {
    email.text = "mohiuddin655.1@gmail.com";
    username.text = "mohiuddin655.1";
    password.text = "123456";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 24,
              ),
              child: Column(
                children: [
                  EditField(
                    controller: email,
                    hint: "Email",
                  ),
                  EditField(
                    controller: username,
                    hint: "Username",
                  ),
                  EditField(
                    controller: password,
                    hint: "Password",
                  ),
                ],
              ),
            ),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("SignIn with Apple"),
                  onPressed: () => controller.signInByApple(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Biometric"),
                  onPressed: () => controller.signInByBiometric(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Email"),
                  onPressed: () => controller.signInByEmail(
                    EmailAuthenticator(
                      email: email.text,
                      password: password.text,
                    ),
                    biometric: true,
                  ),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Facebook"),
                  onPressed: () => controller.signInByFacebook(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Github"),
                  onPressed: () => controller.signInByGithub(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Google"),
                  onPressed: () => controller.signInByGoogle(),
                ),
                ElevatedButton(
                  child: const Text("SignIn with Username"),
                  onPressed: () => controller.signInByUsername(
                    UsernameAuthenticator(
                      username: username.text,
                      password: password.text,
                    ),
                    biometric: true,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("SignUp with Email"),
                  onPressed: () => controller.signUpByEmail(
                    EmailAuthenticator(
                      email: email.text,
                      password: password.text,
                    ),
                    biometric: true,
                  ),
                ),
                ElevatedButton(
                  child: const Text("SignUp with Username"),
                  onPressed: () => controller.signUpByUsername(
                    UsernameAuthenticator(
                      username: username.text,
                      password: password.text,
                    ),
                    biometric: true,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Wrap(
              runSpacing: 12,
              spacing: 12,
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Sign Out"),
                  onPressed: () => controller.signOut(),
                ),
              ],
            ),
            BlocConsumer<AuthController, AuthResponse>(
              builder: (context, state) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  color: Colors.grey.withAlpha(50),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    state.toString(),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              listener: (context, state) {
                if (state.isMessage) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                  ));
                } else if (state.isError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class EditField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const EditField({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
        ),
      ),
    );
  }
}
