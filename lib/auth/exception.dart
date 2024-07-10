import 'auth_credential.dart';

class IAuthException {
  final String? message;
  final String code;
  final String? email;
  final IAuthCredential? credential;
  final String? phoneNumber;
  final String? tenantId;

  const IAuthException({
    this.message,
    required this.code,
    this.email,
    this.credential,
    this.phoneNumber,
    this.tenantId,
  });
}
