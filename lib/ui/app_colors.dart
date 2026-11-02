import 'package:flutter/material.dart';

/// Design tokens and color palette matching Individual BS.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F1EA);
  static const Color card = Colors.white;
  static const Color accent = Color(0xFF2F6F5E);
  static const Color accentMuted = Color(0x1F2F6F5E);
  static const Color accentLight = Color(0xFFE8F2EE);
  static const Color textPrimary = Color(0xFF1E2621);
  static const Color textSecondary = Color(0xFF656B64);
  static const Color textMuted = Color(0xFF8C928B);
  static const Color surfaceMuted = Color(0xFFECE7DE);
  static const Color border = Color(0xFFE4DFD5);
  static const Color cardBorder = Color(0xFFE4DFD5);
  static const Color error = Color(0xFFBA1A1A);

  // Status & Badges
  static const Color gold = Color(0xFFD97706);
  static const Color silver = Color(0xFF6B7280);
  static const Color bronze = Color(0xFFB45309);
  static const Color streakBg = Color(0xFFFBF4E8);
  static const Color streakBorder = Color(0xFFF3DFC1);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: accent.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
