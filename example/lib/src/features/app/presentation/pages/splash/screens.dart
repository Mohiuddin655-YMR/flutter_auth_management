enum SplashScreens {
  none("/splash", "Splash");

  final String name;
  final String title;

  static String get route => none.name;

  const SplashScreens(this.name, this.title);
}
