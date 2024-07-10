import 'exception.dart';

typedef IRecaptchaVerifierClear = void Function();
typedef IRecaptchaVerifierRender = Future<int> Function();
typedef IRecaptchaVerifierVerify = Future<String> Function();
typedef IRecaptchaVerifierOnSuccess = void Function();
typedef IRecaptchaVerifierOnError = void Function(IAuthException exception);
typedef IRecaptchaVerifierOnExpired = void Function();

enum IRecaptchaVerifierSize { normal, compact }

enum IRecaptchaVerifierTheme { light, dark }

class IRecaptchaVerifier {
  final Object auth;
  final String? container;
  final IRecaptchaVerifierSize size;
  final IRecaptchaVerifierTheme theme;
  final String type;

  final IRecaptchaVerifierOnSuccess? onSuccess;
  final IRecaptchaVerifierOnError? onError;
  final IRecaptchaVerifierOnExpired? onExpired;
  final IRecaptchaVerifierClear clear;
  final IRecaptchaVerifierRender render;
  final IRecaptchaVerifierVerify verify;

  const IRecaptchaVerifier({
    required this.auth,
    this.container,
    required this.size,
    required this.theme,
    required this.type,
    this.onSuccess,
    this.onError,
    this.onExpired,
    required this.clear,
    required this.render,
    required this.verify,
  });
}
