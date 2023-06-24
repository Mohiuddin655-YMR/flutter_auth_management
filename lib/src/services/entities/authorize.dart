part of 'entities.dart';

class EmailAuthenticator extends Authenticator {
  EmailAuthenticator({
    required String email,
    required String password,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.provider,
    super.username,
  }) : super(email: email, password: password);

  @override
  String get email => super.email ?? "example@gmail.com";

  @override
  String get password => super.password ?? "123456";
}

class UsernameAuthenticator extends Authenticator {
  UsernameAuthenticator({
    required String username,
    required String password,
    super.id,
    super.timeMills,
    super.email,
    super.name,
    super.phone,
    super.photo,
    super.provider,
  }) : super(username: username, password: password);

  @override
  String get username => super.username ?? "username";

  @override
  String get password => super.password ?? "123456";
}
