import 'package:flutter/material.dart';

/// Central color registry for Agvisely.
///
/// Palette sampled directly from the "Agvisely 2.0" Figma design.
/// Change values here only — every screen reads through these tokens,
/// so a rebrand is a single-file edit.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary leaf green — bottom-nav active, primary buttons, "AG" mark.
  static const Color primary = Color(0xFF5F9E43);

  /// Deep green — logo "G", emphasis, pressed states.
  static const Color primaryDark = Color(0xFF267933);

  /// Bright accent green — highlights, small indicators.
  static const Color accent = Color(0xFF6CC72B);

  /// Navy — the "visely" wordmark, headings on light surfaces.
  static const Color navy = Color(0xFF2E3F4F);

  /// Dark olive — large figures (e.g. temperature), strong headings.
  static const Color heading = Color(0xFF435939);

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
  static const Color textSecondaryLight = Color(0xFF6B7A63);
  static const Color textPrimaryDark = Color(0xFFF1F5EE);
  static const Color textSecondaryDark = Color(0xFFA9B6A2);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF2A93B);
  static const Color danger = Color(0xFFE0533D);
  static const Color info = Color(0xFF3B82C4);
}
