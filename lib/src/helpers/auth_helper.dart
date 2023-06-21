part of 'helpers.dart';

class AuthHelper {
  const AuthHelper._();

  static bool get isLoggedIn => defaultUser != null && uid.isNotEmpty;

  static String get uid => defaultUser?.uid ?? "";

  static User? get defaultUser => FirebaseAuth.instance.currentUser;
}
