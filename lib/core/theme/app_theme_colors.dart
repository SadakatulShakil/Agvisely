import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary leaf green — bottom-nav active, primary buttons, "AG" mark.
  static const Color primary = Color(0xFF5F9E43);

  /// Deep green — logo "G", emphasis, pressed states.
  static const Color primaryDark = Color(0xFF678042);

  /// Bright accent green — highlights, small indicators.
  static const Color accent = Color(0xFF9BB673);

  ///Bar chart color
  static const Color barChart = Color(0xFFB6EBBC);
  static const Color barChartBasic = Color(0xFFFAFCF9);

  ///Line chart temp
  static const Color lineChartTemp = Color(0xFF3D7488);
  static const Color lineChartHumidity = Color(0xFFC2701C);

  /// Navy — the "visely" wordmark, headings on light surfaces.
  static const Color navy = Color(0xFF2E3F4F);

  /// Dark olive — large figures (e.g. temperature), strong headings.
  static const Color heading = Color(0xFF98A894);

  // ── Surfaces (light) ───────────────────────────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF2F4F1); // sage off-white
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardMint = Color(0xFFE9F4E4); // "My Choice" / soft tiles
  static const Color dividerLight = Color(0xFFE3E7E0);

  // ── Surfaces (dark) ──────────────────────────────────────────────────────
  static const Color scaffoldDark = Color(0xFF121712);
  static const Color cardDark = Color(0xFF1C241B);
  static const Color dividerDark = Color(0xFF2A332A);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1E2A18);
  static const Color textSecondaryLight = Color(0xFFB1BDA0);
  static const Color textPrimaryDark = Color(0xFFF1F5EE);
  static const Color textSecondaryDark = Color(0xFFA9B6A2);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF2A93B);
  static const Color danger = Color(0xFFE0533D);
  static const Color info = Color(0xFF3B82C4);
}

class FigmaColors {
  FigmaColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  /// Primary/Dark — headings, app bar, pressed.
  static const Color primaryDark = Color(0xFF435939);

  /// Primary/Default — brand, primary buttons.
  static const Color primaryDefault = Color(0xFF678042);

  /// Primary/Active — active / selected state.
  static const Color primaryActive = Color(0xFF5F9E43);

  /// Primary/Light — secondary accents.
  static const Color primaryLight = Color(0xFF9BB673);

  /// Primary/Tint — chips, selected backgrounds.
  static const Color primaryTint = Color(0xFFE9F4E4);

  // ── Neutral ──────────────────────────────────────────────────────────────
  /// Neutral/Black — max-contrast text.
  static const Color neutralBlack = Color(0xFF000000);

  /// Neutral/Body — body text.
  static const Color neutralBody = Color(0xFF6A7268);

  /// Neutral/Secondary — secondary text, icons.
  static const Color neutralSecondary = Color(0xFF929791);

  /// Neutral/Placeholder — placeholder, disabled.
  static const Color neutralPlaceholder = Color(0xFFB1BDA0);

  /// Neutral/Border — card & input borders.
  static const Color neutralBorder = Color(0xFFE5E8E0);

  /// Neutral/Divider — dividers, lines.
  static const Color neutralDivider = Color(0xFFE7EBE5);

  /// Neutral/Background — app background.
  static const Color neutralBackground = Color(0xFFF2F4F1);

  /// Neutral/Surface — cards, sheets.
  static const Color neutralSurface = Color(0xFFFAFCF9);

  /// Neutral/White — pure white.
  static const Color neutralWhite = Color(0xFFFFFFFF);

  // ── Chart ────────────────────────────────────────────────────────────────
  /// Chart/Rainfall — rainfall bars.
  static const Color chartRainfall = Color(0xFFB6EBBC);
  /// Chart/Temperature — temperature line.
  static const Color chartTemperature = Color(0xFF3D7488);
  /// Chart/Humidity — humidity line.
  static const Color chartHumidity = Color(0xFFC2701C);
  /// Status error — e.g. "No data" or "Failed to load".
  static const Color statusError = Color(0xFFEA0C0C);
}
