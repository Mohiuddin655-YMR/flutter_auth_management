class IUserMetadata {
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  const IUserMetadata({
    this.creationTime,
    this.lastSignInTime,
  });
}
