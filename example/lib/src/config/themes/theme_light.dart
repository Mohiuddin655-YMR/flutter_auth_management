part of 'theme.dart';

ThemeData _light = ThemeData.from(
  useMaterial3: true,
  colorScheme: AppColors.colorScheme.light,
).copyWith(
  /// BASE PROPERTIES
  scaffoldBackgroundColor: AppColors.background.light,
  splashColor: Colors.black12,

  /// APPBAR PROPERTIES
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.appbar.light,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: AppColors.appbarIcon.light,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      color: AppColors.appbarTitle.light,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: AppColors.appbar.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    elevation: 0.5,
    color: AppColors.appbar.light,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.black.t50,
  ),

  /// BODY PROPERTIES

  dividerTheme: DividerThemeData(
    color: AppColors.raw.dark.t10,
  ),

  iconTheme: IconThemeData(
    color: AppColors.bodyIcon.light,
  ),

  textTheme: TextTheme(
    titleMedium: TextStyle(
      color: AppColors.bodyTitleMedium.light,
      fontSize: 16,
      fontFamily: "",
      fontWeight: FontWeight.normal,
    ),
    titleSmall: TextStyle(
      color: AppColors.bodySubtitle.light,
      fontSize: 14,
      fontFamily: "",
      fontWeight: FontWeight.normal,
    ),
  ),
);
