enum AuthProviders {
  // OAUTH
  apple,
  facebook,
  gameCenter,
  github,
  google,
  microsoft,
  playGames,
  saml,
  twitter,
  yahoo,
  // CUSTOM
  biometric,
  email,
  guest,
  phone,
  username,
  none;

  factory AuthProviders.from(String? source) {
    // OAUTH
    if (source == apple.name) {
      return AuthProviders.apple;
    } else if (source == facebook.name) {
      return AuthProviders.facebook;
    } else if (source == gameCenter.name) {
      return AuthProviders.gameCenter;
    } else if (source == github.name) {
      return AuthProviders.github;
    } else if (source == google.name) {
      return AuthProviders.google;
    } else if (source == microsoft.name) {
      return AuthProviders.microsoft;
    } else if (source == playGames.name) {
      return AuthProviders.playGames;
    } else if (source == saml.name) {
      return AuthProviders.saml;
    } else if (source == twitter.name) {
      return AuthProviders.twitter;
    } else if (source == yahoo.name) {
      return AuthProviders.yahoo;
    } else
    // CUSTOM
    if (source == biometric.name) {
      return AuthProviders.biometric;
    } else if (source == email.name) {
      return AuthProviders.email;
    } else if (source == guest.name) {
      return AuthProviders.guest;
    } else if (source == phone.name) {
      return AuthProviders.phone;
    } else if (source == username.name) {
      return AuthProviders.username;
    } else {
      return AuthProviders.none;
    }
  }

  // OAUTH
  bool get isApple => this == AuthProviders.apple;

  bool get isFacebook => this == AuthProviders.facebook;

  bool get isGameCenter => this == AuthProviders.gameCenter;

  bool get isGithub => this == AuthProviders.github;

  bool get isGoogle => this == AuthProviders.google;

  bool get isMicrosoft => this == AuthProviders.microsoft;

  bool get isPlayGames => this == AuthProviders.playGames;

  bool get isSAML => this == AuthProviders.saml;

  bool get isTwitter => this == AuthProviders.twitter;

  bool get isYahoo => this == AuthProviders.yahoo;

  // CUSTOM
  bool get isBiometric => this == AuthProviders.biometric;

  bool get isEmail => this == AuthProviders.email;

  bool get isGuest => this == AuthProviders.guest;

  bool get isPhone => this == AuthProviders.phone;

  bool get isUsername => this == AuthProviders.username;

  bool get isNone => this == AuthProviders.none;

  bool get isAllowBiometric => isEmail || isUsername;

  bool get isVerified => !(isNone || isEmail || isUsername);
}
