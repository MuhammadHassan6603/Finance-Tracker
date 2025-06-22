import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: ThemeConstants.fontFamily,
      colorScheme: _buildLightColorScheme(),
      textTheme: _buildTextTheme(isLight: true),
      cardTheme: _buildCardTheme(isLight: true),
      inputDecorationTheme: _buildInputDecorationTheme(isLight: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      iconTheme: _buildIconTheme(isLight: true),
      appBarTheme: _buildAppBarTheme(isLight: true),
      bottomNavigationBarTheme: _buildBottomNavBarTheme(isLight: true),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: ThemeConstants.fontFamily,
      colorScheme: _buildDarkColorScheme(),
      textTheme: _buildTextTheme(isLight: false),
      cardTheme: _buildCardTheme(isLight: false),
      inputDecorationTheme: _buildInputDecorationTheme(isLight: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      iconTheme: _buildIconTheme(isLight: false),
      appBarTheme: _buildAppBarTheme(isLight: false),
      bottomNavigationBarTheme: _buildBottomNavBarTheme(isLight: false),
    );
  }

  static ColorScheme _buildLightColorScheme() {
    return const ColorScheme.light(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.secondaryColor,
      tertiary: ThemeConstants.accentColor,
      background: ThemeConstants.backgroundLight,
      surface: ThemeConstants.surfaceLight,
      onBackground: ThemeConstants.textPrimaryLight,
      onSurface: ThemeConstants.textPrimaryLight,
    );
  }

  static ColorScheme _buildDarkColorScheme() {
    return const ColorScheme.dark(
      primary: ThemeConstants.primaryColor,
      secondary: ThemeConstants.secondaryColor,
      tertiary: ThemeConstants.accentColor,
      background: ThemeConstants.backgroundDark,
      surface: ThemeConstants.surfaceDark,
      onBackground: ThemeConstants.textPrimaryDark,
      onSurface: ThemeConstants.textPrimaryDark,
    );
  }

  static TextTheme _buildTextTheme({required bool isLight}) {
    final textColor = isLight
        ? ThemeConstants.textPrimaryLight
        : ThemeConstants.textPrimaryDark;
    final subtextColor = isLight
        ? ThemeConstants.textSecondaryLight
        : ThemeConstants.textSecondaryDark;

    return TextTheme(
      headlineLarge: ThemeConstants.headlineLarge.copyWith(color: textColor),
      headlineMedium: ThemeConstants.headlineMedium.copyWith(color: textColor),
      titleLarge: ThemeConstants.titleLarge.copyWith(color: textColor),
      titleMedium: ThemeConstants.titleMedium.copyWith(color: textColor),
      bodyLarge: ThemeConstants.bodyLarge.copyWith(color: textColor),
      bodyMedium: ThemeConstants.bodyMedium.copyWith(color: subtextColor),
    );
  }

  static CardThemeData _buildCardTheme({required bool isLight}) {
    return CardThemeData(
      color: isLight ? ThemeConstants.cardLight : ThemeConstants.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMedium),
        side: BorderSide(
          color: (isLight
                  ? ThemeConstants.inputBorderLight
                  : ThemeConstants.inputBorderDark)
              .withOpacity(0.1),
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(
      {required bool isLight}) {
    return InputDecorationTheme(
      filled: true,
      fillColor:
          isLight ? ThemeConstants.surfaceLight : ThemeConstants.surfaceDark,
      border: _buildInputBorder(isLight: isLight),
      enabledBorder: _buildInputBorder(isLight: isLight),
      focusedBorder: _buildInputBorder(
        isLight: isLight,
        color: ThemeConstants.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingMedium,
      ),
    );
  }

  static OutlineInputBorder _buildInputBorder({
    required bool isLight,
    Color? color,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
      borderSide: BorderSide(
        color: color ??
            (isLight
                ? ThemeConstants.inputBorderLight
                : ThemeConstants.inputBorderDark),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
        elevation: 0,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.primaryColor,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  static IconThemeData _buildIconTheme({required bool isLight}) {
    return IconThemeData(
      color: isLight
          ? ThemeConstants.textPrimaryLight
          : ThemeConstants.textPrimaryDark,
      size: 24,
    );
  }

  static AppBarTheme _buildAppBarTheme({required bool isLight}) {
    return AppBarTheme(
      backgroundColor: isLight
          ? ThemeConstants.backgroundLight
          : ThemeConstants.backgroundDark,
      foregroundColor: isLight
          ? ThemeConstants.textPrimaryLight
          : ThemeConstants.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavBarTheme(
      {required bool isLight}) {
    return BottomNavigationBarThemeData(
      backgroundColor:
          isLight ? ThemeConstants.surfaceLight : ThemeConstants.surfaceDark,
      selectedItemColor: ThemeConstants.primaryColor,
      unselectedItemColor: isLight
          ? ThemeConstants.textSecondaryLight
          : ThemeConstants.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
}
