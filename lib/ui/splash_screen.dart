import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Animated splash screen shown at startup.
///
/// Features:
/// - Light background (#F4F1EA), centered.
/// - Centered logo (assets/icon/logo_b.png, 90 px) with fade + gentle scale-in (0.8 -> 1.0, 600 ms).
/// - 150 px circular CustomPaint loader: light-blue ring (#B7E3FF, stroke 6) +
///   rotating bright blue arc (#38B6FF, stroke 6, round caps, ~100 degrees, 1.2 s per turn).
/// - Fading-in localized "Bisrat Bible Study" title in Noto Sans Ethiopic.
/// - Error fallback with "Try again" button if loading fails or times out (>15 s).
class SplashScreen extends StatefulWidget {
  final bool showRetry;
  final VoidCallback? onRetry;
  final String? errorMessage;

  const SplashScreen({
    super.key,
    this.showRetry = false,
    this.onRetry,
    this.errorMessage,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // 600 ms entry animation (fade-in & scale 0.8 -> 1.0)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    _entryController.forward();

    // 1.2 s continuous rotation for the bright blue arc
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (!widget.showRetry) {
      _rotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showRetry != widget.showRetry) {
      if (widget.showRetry) {
        _rotateController.stop();
      } else {
        _rotateController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appName = l10n?.splashAppName ?? 'Bisrat Bible Study';
    final retryText = l10n?.splashRetry ?? 'Try again';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── 150 px Loader + 90 px Centered Logo ───────────────────────
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating loader ring & arc
                      AnimatedBuilder(
                        animation: _rotateController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(150, 150),
                            painter: _SplashRingPainter(
                              rotationAngle:
                                  _rotateController.value * 2 * math.pi,
                            ),
                          );
                        },
                      ),
                      // Centered 90 px Logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Image.asset(
                            'assets/icon/logo_b.png',
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Fading App Title ──────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    appName,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ── Error Fallback / "Try again" ──────────────────────────────
                if (widget.showRetry) ...[
                  const SizedBox(height: 20),
                  if (widget.errorMessage != null) ...[
                    Text(
                      widget.errorMessage!,
                      style: AppTextStyles.caption(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton(
                    onPressed: widget.onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      retryText,
                      style: AppTextStyles.button(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the 150 px loader ring and rotating arc.
class _SplashRingPainter extends CustomPainter {
  final double rotationAngle;

  const _SplashRingPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Thin light-blue ring (#B7E3FF, stroke 6)
    final ringPaint = Paint()
      ..color = const Color(0xFFB7E3FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, ringPaint);

    // Bright blue arc (#38B6FF, stroke 6, round caps, ~100 degrees)
    final arcPaint = Paint()
      ..color = const Color(0xFF38B6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const double sweepAngle = 100.0 * (math.pi / 180.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotationAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashRingPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
