class AuthValidator {
  const AuthValidator._();

  static bool isValidEmail(String? email) {
    return email != null && email.length >= 5;
  }

  static bool isValidPhone(String? phone) {
    return phone != null && phone.length >= 5;
  }

  static bool isValidPassword(String? password) {
    return password != null && password.length >= 6;
  }

  static bool isValidSmsCode(String? code) {
    return code != null && code.length >= 3;
  }

  static bool isValidToken(String? token) {
    return token != null && token.length >= 30;
  }

  static bool isValidUsername(String? username) {
    return username != null && username.length >= 3;
  }
}
