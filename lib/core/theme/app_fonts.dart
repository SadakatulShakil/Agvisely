import 'package:flutter/material.dart';

/// Central font registry — AnekBangla is bundled in
/// assets/fonts/ and declared in pubspec.yaml, so text
/// renders with the correct typeface on the very first
/// frame (no async google_fonts load → no size-flash on
/// cold start, works fully offline).
class AppFonts {
  AppFonts._();

  static const String family = 'AnekBangla';

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
