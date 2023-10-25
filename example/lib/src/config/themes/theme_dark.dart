part of 'theme.dart';

ThemeData _dark = ThemeData.from(
  useMaterial3: true,
  colorScheme: AppColors.colorScheme.dark,
).copyWith(
  /// BASE PROPERTIES
  scaffoldBackgroundColor: AppColors.background.dark,
  splashColor: Colors.white12,

  /// APPBAR PROPERTIES
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.appbar.dark,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: AppColors.appbarIcon.dark,
    ),
    titleTextStyle: TextStyle(
      color: AppColors.appbarTitle.dark,
      fontSize: 18,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: AppColors.appbar.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  ),

  /// BODY PROPERTIES
  dividerTheme: DividerThemeData(
    color: AppColors.raw.dark.t10,
  ),

  iconTheme: IconThemeData(
    color: AppColors.bodyIcon.dark,
  ),

  textTheme: TextTheme(
    titleMedium: TextStyle(
      color: AppColors.bodyTitleMedium.dark,
      fontSize: 16,
      fontFamily: "",
      fontWeight: FontWeight.normal,
    ),
    titleSmall: TextStyle(
      color: AppColors.bodySubtitle.dark,
      fontSize: 14,
      fontFamily: "",
      fontWeight: FontWeight.normal,
    ),
  ),

  /// NONE
  bottomAppBarTheme: BottomAppBarTheme(
    elevation: 0.5,
    color: AppColors.appbar.dark,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.white.t50,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.appbar.dark,
    surfaceTintColor: AppColors.appbar.dark,
  ),
);
