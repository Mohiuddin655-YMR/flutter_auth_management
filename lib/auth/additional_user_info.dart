class IAdditionalUserInfo {
  final bool isNewUser;
  final Map<String, dynamic>? profile;
  final String? providerId;
  final String? username;
  final String? authorizationCode;

  const IAdditionalUserInfo({
    required this.isNewUser,
    this.profile,
    this.providerId,
    this.username,
    this.authorizationCode,
  });
}
