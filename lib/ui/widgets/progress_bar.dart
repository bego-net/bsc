import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Smooth rounded progress bar with calm green accent and soft track.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color backgroundColor;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.fillColor = AppColors.accent,
    this.backgroundColor = AppColors.surfaceMuted,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Container(
        height: height,
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * clamped,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
