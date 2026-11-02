import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Rounded pill chip displaying a stat or status tag.
class StatChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onTap;

  const StatChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.surfaceMuted,
    this.borderColor = AppColors.border,
    this.textColor = AppColors.textPrimary,
    this.onTap,
  });

  factory StatChip.streak(String label) => StatChip(
        label: label,
        icon: const Text('🔥', style: TextStyle(fontSize: 14)),
        backgroundColor: AppColors.streakBg,
        borderColor: AppColors.streakBorder,
        textColor: AppColors.bronze,
      );

  factory StatChip.accent(String label, {Widget? icon}) => StatChip(
        label: label,
        icon: icon,
        backgroundColor: AppColors.accent.withValues(alpha: 0.1),
        borderColor: AppColors.accent.withValues(alpha: 0.25),
        textColor: AppColors.accent,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.caption(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
