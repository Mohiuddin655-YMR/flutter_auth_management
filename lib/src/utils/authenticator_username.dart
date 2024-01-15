import 'authenticator.dart';

class UsernameAuthenticator extends Authenticator {
  UsernameAuthenticator({
    required super.username,
    required super.password,
    super.id,
    super.timeMills,
    super.email,
    super.name,
    super.phone,
    super.photo,
    super.provider,
  }) : super.username();

  @override
  String get username => super.username ?? "username";

  @override
  String get password => super.password ?? "123456";
}
