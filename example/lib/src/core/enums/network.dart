import '../../../index.dart';

enum NetworkEnums {
  login(ApiConstants.login),
  introOff('introOff'),
  token('token');

  final String path;

  const NetworkEnums(this.path);
}
