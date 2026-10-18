import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_theme_colors.dart';

/// Builds the app-wide [ThemeData] for light and dark modes.
///
/// Same system as BMD (AnekBangla bundled font, Material 3, GetX
/// `theme:`/`darkTheme:` wiring) — only the color source differs,
/// now driven by [AppColors].
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.cardLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      fontFamily: AppFonts.family,
      textTheme: AppFonts.textTheme(ThemeData.light().textTheme),
      primaryTextTheme: AppFonts.textTheme(ThemeData.light().primaryTextTheme),
      dialogTheme: DialogThemeData(
        titleTextStyle: ThemeData.light().textTheme.titleLarge
            ?.copyWith(fontFamily: AppFonts.family, color: AppColors.navy),
        contentTextStyle: ThemeData.light().textTheme.bodyMedium
            ?.copyWith(fontFamily: AppFonts.family, color: AppColors.textPrimaryLight),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: ThemeData.light().textTheme.titleMedium
            ?.copyWith(fontFamily: AppFonts.family, color: Colors.white),
      ),
      dividerColor: AppColors.dividerLight,
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldLight,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.cardDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      fontFamily: AppFonts.family,
      textTheme: AppFonts.textTheme(ThemeData.dark().textTheme),
      primaryTextTheme: AppFonts.textTheme(ThemeData.dark().primaryTextTheme),
      dialogTheme: DialogThemeData(
        titleTextStyle: ThemeData.dark().textTheme.titleLarge
            ?.copyWith(fontFamily: AppFonts.family, color: AppColors.textPrimaryDark),
        contentTextStyle: ThemeData.dark().textTheme.bodyMedium
            ?.copyWith(fontFamily: AppFonts.family, color: AppColors.textPrimaryDark),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: ThemeData.dark().textTheme.titleMedium
            ?.copyWith(fontFamily: AppFonts.family, color: Colors.white),
      ),
      dividerColor: AppColors.dividerDark,
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
