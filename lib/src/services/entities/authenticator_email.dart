part of 'entities.dart';

class EmailAuthenticator extends Authenticator {
  EmailAuthenticator({
    required super.email,
    required super.password,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.provider,
    super.username,
  }) : super.email();

  @override
  String get email => super.email ?? "example@gmail.com";

  @override
  String get password => super.password ?? "123456";
}
