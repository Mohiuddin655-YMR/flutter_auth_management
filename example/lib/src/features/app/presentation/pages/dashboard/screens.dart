enum DashboardScreens {
  none("/", "Home");

  final String name;
  final String title;

  static String get route => none.name;

  const DashboardScreens(this.name, this.title);
}
