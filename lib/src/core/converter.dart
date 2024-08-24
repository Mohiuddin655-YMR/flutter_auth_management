/// Provides methods for modifying and converting values.
class AuthConverter {
  const AuthConverter._();

  /// Converts prefix, suffix, and type to a formatted email address.
  ///
  /// Example: ('john.doe', 'example', 'com') -> 'john.doe@example.com'
  static String? toMail(
    String prefix,
    String suffix, [
    String type = "com",
  ]) {
    return "$prefix@$suffix.$type";
  }
}
