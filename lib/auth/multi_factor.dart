typedef IMultiFactorGetSession = Future<IMultiFactorSession> Function();
typedef IMultiFactorEnroll = Future<void> Function(
  IMultiFactorAssertion assertion, {
  String? displayName,
});

typedef IMultiFactorUnenroll = Future<void> Function({
  String? factorUid,
  IMultiFactorInfo? multiFactorInfo,
});

typedef IMultiFactorGetEnrolledFactors = Future<List<IMultiFactorInfo>>
    Function();

abstract class IMultiFactor {
  /// CALLBACKS
  final IMultiFactorGetSession getSession;
  final IMultiFactorEnroll enroll;
  final IMultiFactorUnenroll unenroll;
  final IMultiFactorGetEnrolledFactors getEnrolledFactors;

  const IMultiFactor({
    /// CALLBACKS
    required this.getSession,
    required this.enroll,
    required this.unenroll,
    required this.getEnrolledFactors,
  });
}

class IMultiFactorSession {
  final String id;

  const IMultiFactorSession(this.id);
}

class IMultiFactorInfo {
  final String? displayName;
  final double enrollmentTimestamp;
  final String factorId;
  final String uid;

  const IMultiFactorInfo({
    required this.factorId,
    required this.enrollmentTimestamp,
    this.displayName,
    required this.uid,
  });
}

class IMultiFactorAssertion {}

class IPhoneMultiFactorInfo extends IMultiFactorInfo {
  final String phoneNumber;

  const IPhoneMultiFactorInfo({
    required super.displayName,
    required super.enrollmentTimestamp,
    required super.factorId,
    required super.uid,
    required this.phoneNumber,
  });
}
