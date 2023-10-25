import 'package:app_color/app_color.dart';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static final raw = ThemeColor(
    light: const Color(0xff84959f),
    dark: const Color(0xff84959f),
  );

  static final primary = ThemeColor(
    light: const Color(0xff008069),
  );

  static final secondary = ThemeColor(
    light: Colors.blueGrey,
    dark: Colors.blueGrey,
  );

  static final ternary = ThemeColor(
    light: Colors.grey,
    dark: Colors.grey,
  );

  static final background = ThemeColor(
    light: const Color(0xffffffff),
    dark: const Color(0xff121b22),
  );

  static final error = ThemeColor(
    light: Colors.red,
    dark: Colors.red,
  );

  static final disable = ThemeColor(
    light: Colors.grey,
    dark: Colors.grey,
  );

  /// APP BAR COLORS
  static final appbar = ThemeColor(
    light: const Color(0xff008069),
    dark: const Color(0xff1f2c34),
  );

  static final appbarIcon = ThemeColor(
    light: const Color(0xffffffff),
  );

  static final appbarTitle = ThemeColor(
    light: const Color(0xffffffff),
  );

  /// BOTTOM SHEET COLORS
  static final bottomSheet = ThemeColor(
    light: Colors.white,
    dark: DarkColors.darkJungleGreen,
  );

  /// BODY COLORS
  static final bodyIcon = ThemeColor(
    light: const Color(0xff84959f),
    dark: const Color(0xff84959f),
  );

  static final bodyTitleMedium = ThemeColor(
    light: const Color(0xff121b22),
    dark: const Color(0xffe8edf1),
  );

  static final bodySubtitle = ThemeColor(
    light: const Color(0xff667781),
    dark: const Color(0xff667781),
  );

  static final textColor = ThemeColor(
    light: Colors.black,
    dark: Colors.white,
  );

  static final colorScheme = ThemeColorScheme.fromThemeColor(
    primary: primary,
    secondary: secondary,
    ternary: ternary,
    error: error,
    background: background,
  );
}
