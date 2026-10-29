import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Central font registry — AnekBangla (bn) and Outfit (en, the Google Font)
class AppFonts {
  AppFonts._();

  static const String banglaFamily = 'AnekBangla';
  static const String englishFamily = 'Outfit';

  static String familyFor(String? languageCode) =>
      languageCode == 'en' ? englishFamily : banglaFamily;

  static String get family => familyFor(Get.locale?.languageCode);

  static TextStyle style({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    Paint? background,
    Color? backgroundColor,
    List<Shadow>? shadows,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final base = TextStyle(
      fontFamily: family,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      background: background,
      backgroundColor: backgroundColor,
      shadows: shadows,
    );
    return textStyle == null ? base : textStyle.merge(base);
  }

  static TextTheme textTheme([TextTheme? base]) {
    final t = base ?? const TextTheme();
    return t.apply(fontFamily: family);
  }
}
