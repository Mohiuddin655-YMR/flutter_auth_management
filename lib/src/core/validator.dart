import 'patterns.dart';

class AuthValidator {
  const AuthValidator._();

  static bool isValidEmail(String? email, [RegExp? pattern]) {
    return email != null &&
        email.isNotEmpty &&
        (pattern ?? AuthPatterns.email).hasMatch(email);
  }

  static bool isValidPhone(String? phone, [RegExp? pattern]) {
    return phone != null &&
        phone.isNotEmpty &&
        (pattern ?? AuthPatterns.phone).hasMatch(phone);
  }

  static bool isValidPassword(
    String? password, {
    int minLength = 6,
    int maxLength = 20,
    RegExp? pattern,
  }) {
    return isValid(
      password,
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
    );
  }

  static bool isValidSmsCode(String? code) {
    return isValid(code);
  }

  static bool isValidToken(String? token) {
    return isValid(token);
  }

  static bool isValid(
    String? value, {
    int minLength = 6,
    int maxLength = 20,
    RegExp? pattern,
  }) {
    bool a = value != null && value.isNotEmpty && value.toLowerCase() != "null";
    bool b = maxLength <= 0 ? a : a && value.length <= maxLength;
    bool c = b && value.length >= minLength;
    bool d = pattern != null ? pattern.hasMatch(value ?? '') : c;
    return d;
  }

  static bool isValidRetypePassword(String? password, String? retypePassword) {
    return isValidPassword(password) && password == retypePassword;
  }

  static bool isValidUsername(
    String? username, {
    bool withDot = true,
    RegExp? pattern,
  }) {
    if (username != null && username.isNotEmpty) {
      if (withDot) {
        return (pattern ?? AuthPatterns.usernameWithDot).hasMatch(username);
      } else {
        return (pattern ?? AuthPatterns.username).hasMatch(username);
      }
    } else {
      return false;
    }
  }
}
