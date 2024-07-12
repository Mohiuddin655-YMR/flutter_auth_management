enum BiometricStatus {
  initial,
  activated,
  deactivated;

  bool get isInitial => this == initial;

  bool get isActivated => this == activated;

  bool get isDeactivated => this == deactivated;

  factory BiometricStatus.from(String? source) {
    final key = source?.toLowerCase();
    if (key == BiometricStatus.activated.name) {
      return BiometricStatus.activated;
    } else if (key == BiometricStatus.deactivated.name) {
      return BiometricStatus.deactivated;
    } else {
      return BiometricStatus.initial;
    }
  }

  factory BiometricStatus.value(bool value) {
    return value ? BiometricStatus.activated : BiometricStatus.deactivated;
  }
}
