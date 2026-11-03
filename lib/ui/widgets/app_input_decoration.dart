import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Returns a consistent [InputDecoration] matching the app design system.
InputDecoration appInputDecoration({
  required String label,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    labelStyle: AppTextStyles.caption(),
    hintStyle: AppTextStyles.caption(color: AppColors.textMuted),
    prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20) : null,
    suffixIcon: suffixIcon,
    errorText: errorText,
    errorStyle: AppTextStyles.caption(color: AppColors.error),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1.8),
    ),
  );
}
