class IIdTokenResult {
  final DateTime? authTime;
  final Map<String, dynamic>? claims;
  final DateTime? expirationTime;
  final DateTime? issuedAtTime;
  final String? signInProvider;
  final String? token;

  const IIdTokenResult({
    this.authTime,
    this.claims,
    this.expirationTime,
    this.issuedAtTime,
    this.signInProvider,
    this.token,
  });
}
