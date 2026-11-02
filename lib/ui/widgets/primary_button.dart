import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Full-width primary button with height 54px, radius 16, and optional loading or outlined states.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isTonal;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double radius;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isTonal = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 54.0,
    this.radius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ??
        (isTonal ? AppColors.accent.withValues(alpha: 0.14) : AppColors.accent);
    final fg = foregroundColor ??
        (isOutlined || isTonal ? AppColors.accent : Colors.white);

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.button(color: fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      childContent = Text(
        label,
        style: AppTextStyles.button(color: fg),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.accent.withValues(alpha: 0.08),
            side: BorderSide(color: fg, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: childContent,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: childContent,
      ),
    );
  }
}
