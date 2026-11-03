import 'package:flutter/material.dart';

/// Design tokens and color palette for the Bible Study light theme.
class AppColors {
  AppColors._();

  // ── Core palette ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F1EA); // warm off-white
  static const Color surface = Color(0xFFEAE5DA);    // light beige surface
  static const Color card = Colors.white;
  static const Color accent = Color(0xFF2F6F5E);     // primary green
  static const Color accentMuted = Color(0x1F2F6F5E);
  static const Color accentLight = Color(0xFFE5EEEA); // muted sage
  static const Color sage = Color(0xFFE5EEEA);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF202B26);   // dark text
  static const Color textSecondary = Color(0xFF69736D); // secondary text
  static const Color textMuted = Color(0xFF8C928B);

  // ── Borders & surfaces ───────────────────────────────────────────────────────
  static const Color surfaceMuted = Color(0xFFECE7DE);
  static const Color border = Color(0xFFE4DFD5);
  static const Color cardBorder = Color(0xFFE4DFD5);
  static const Color divider = Color(0xFFECE7DE);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2F6F5E);

  // ── Status & badges ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFD97706);
  static const Color silver = Color(0xFF6B7280);
  static const Color bronze = Color(0xFFB45309);
  static const Color streakBg = Color(0xFFFBF4E8);
  static const Color streakBorder = Color(0xFFF3DFC1);

  // ── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get pillShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
}
