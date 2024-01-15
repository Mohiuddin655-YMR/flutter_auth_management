import '../widgets/provider.dart';

class AuthProviderException {
  final String exception;

  const AuthProviderException(this.exception);

  bool get isInitialized => AuthProvider.type != null;

  String get message {
    if (isInitialized) {
      return exception;
    } else {
      return "AuthProvider not initialization.";
    }
  }

  @override
  String toString() => message;
}
