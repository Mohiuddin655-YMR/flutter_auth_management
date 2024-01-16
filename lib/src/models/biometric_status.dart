enum BiometricStatus {
  initial,
  activated,
  inactivated;

  bool get isInitial => this == initial;

  bool get isActivated => this == activated;

  bool get isInactivated => this == inactivated;

  factory BiometricStatus.from(String? source) {
    final key = source?.toLowerCase();
    if (key == BiometricStatus.activated.name) {
      return BiometricStatus.activated;
    } else if (key == BiometricStatus.inactivated.name) {
      return BiometricStatus.inactivated;
    } else {
      return BiometricStatus.initial;
    }
  }

  factory BiometricStatus.value(bool value) {
    return value ? BiometricStatus.activated : BiometricStatus.inactivated;
  }
}
