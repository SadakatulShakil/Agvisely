import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the app's light/dark mode.
///
/// Ported from BMD but decoupled from the weather-condition theming
/// that app layered on top — Agvisely is a plain light/dark toggle.
class ThemeController extends GetxController {
  static const _themeKey = 'isDarkMode';

  final themeMode = ThemeMode.light.obs;

  bool get isDark => themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  void toggleTheme(bool isDark) async {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    Get.changeThemeMode(themeMode.value);
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to light for Agvisely (BMD defaulted to dark).
    final dark = prefs.getBool(_themeKey) ?? false;
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }
}
