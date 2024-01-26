enum AuthProviders {
  apple,
  biometric,
  email,
  facebook,
  github,
  google,
  phone,
  twitter,
  username,
  none;

  factory AuthProviders.from(String? source) {
    if (source == apple.name) {
      return AuthProviders.apple;
    } else if (source == biometric.name) {
      return AuthProviders.biometric;
    } else if (source == email.name) {
      return AuthProviders.email;
    } else if (source == facebook.name) {
      return AuthProviders.facebook;
    } else if (source == github.name) {
      return AuthProviders.github;
    } else if (source == google.name) {
      return AuthProviders.google;
    } else if (source == phone.name) {
      return AuthProviders.phone;
    } else if (source == twitter.name) {
      return AuthProviders.twitter;
    } else if (source == username.name) {
      return AuthProviders.username;
    } else {
      return AuthProviders.none;
    }
  }

  bool get isApple => this == AuthProviders.apple;

  bool get isBiometric => this == AuthProviders.biometric;

  bool get isEmail => this == AuthProviders.email;

  bool get isFacebook => this == AuthProviders.facebook;

  bool get isGithub => this == AuthProviders.github;

  bool get isGoogle => this == AuthProviders.google;

  bool get isPhone => this == AuthProviders.phone;

  bool get isTwitter => this == AuthProviders.twitter;

  bool get isUsername => this == AuthProviders.username;

  bool get isNone => this == AuthProviders.none;

  bool get isAllowBiometric => isEmail || isUsername;

  bool get isVerified => !(isNone || isEmail || isUsername);
}
