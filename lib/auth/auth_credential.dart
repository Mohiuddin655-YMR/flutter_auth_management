class IAuthCredential {
  final String providerId;
  final String signInMethod;
  final int? token;
  final String? accessToken;

  const IAuthCredential({
    required this.providerId,
    required this.signInMethod,
    this.token,
    this.accessToken,
  });
}
