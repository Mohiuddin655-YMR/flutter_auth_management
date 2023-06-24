import 'package:auth_management/core.dart';

class AuthManager extends AuthHandlerImpl {
  final AuthDataSource authDataSource;

  AuthManager(this.authDataSource)
      : super(repository: AuthRepositoryImpl(source: authDataSource));
}
