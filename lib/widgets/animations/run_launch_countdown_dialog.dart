import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Fullscreen cinematic "Hyper-Launch" 3-2-1 countdown overlay
/// with warp speed lines, neon concentric shockwave rings,
/// revving gauge telemetry, and seamless zoom launch.
class RunLaunchCountdownDialog extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  final VoidCallback? onCancel;
  final String? routeTitle;

  const RunLaunchCountdownDialog({
    super.key,
    required this.onCountdownComplete,
    this.onCancel,
    this.routeTitle,
  });

  /// Static helper to trigger the countdown modal seamlessly
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onComplete,
    VoidCallback? onCancel,
    String? routeTitle,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, anim1, anim2) {
        return RunLaunchCountdownDialog(
          onCountdownComplete: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            onComplete();
          },
          onCancel: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            if (onCancel != null) onCancel();
          },
          routeTitle: routeTitle,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: child,
        );
      },
    );
  }

  @override
  State<RunLaunchCountdownDialog> createState() =>
      _RunLaunchCountdownDialogState();
}

class _RunLaunchCountdownDialogState extends State<RunLaunchCountdownDialog>
    with TickerProviderStateMixin {
  late AnimationController _stepController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  int _currentCount = 3; // 3 -> 2 -> 1 -> 0 (GO!)
  bool _isGoState = false;

  final List<_WarpParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Generate background warp speed particles
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _WarpParticle(
          angle: _random.nextDouble() * 2 * math.pi,
          radius: 40 + _random.nextDouble() * 220,
          speed: 0.5 + _random.nextDouble() * 1.5,
          size: 1.5 + _random.nextDouble() * 2.5,
          color: i % 3 == 0
              ? AppColors.primaryTeal
              : (i % 3 == 1 ? AppColors.mint : Colors.white),
        ),
      );
    }

    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startCountdownSequence();
  }

  void _startCountdownSequence() async {
    // 3
    _currentCount = 3;
    await _stepController.forward(from: 0.0);
    if (!mounted) return;

    // 2
    setState(() => _currentCount = 2);
    await _stepController.forward(from: 0.0);
    if (!mounted) return;

    // 1
    setState(() => _currentCount = 1);
    await _stepController.forward(from: 0.0);
    if (!mounted) return;

    // GO!
    setState(() {
      _currentCount = 0;
      _isGoState = true;
    });
    await _stepController.forward(from: 0.0);
    if (!mounted) return;

    // Brief explosive flash before completing
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      widget.onCountdownComplete();
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Background Warp Velocity Starfield Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WarpStarfieldPainter(
                      particles: _particles,
                      progress: _particleController.value,
                      isGoState: _isGoState,
                    ),
                  );
                },
              ),
            ),

            // 2. Ambient Glowing Core
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.15);
                return Container(
                  width: 320 * scale,
                  height: 320 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (_isGoState ? AppColors.primaryTeal : AppColors.mint)
                            .withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // 3. Central Shockwave Rings & Countdown Gauge
            AnimatedBuilder(
              animation: _stepController,
              builder: (context, child) {
                final animVal = _stepController.value;
                // Pop scale: bursts large and settles
                final numberScale = _isGoState
                    ? (1.0 + (1.0 - animVal) * 0.8)
                    : (1.35 - (animVal * 0.35));
                final ringRadius = 110 + (animVal * 40);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric Animated Ripple Rings
                    CustomPaint(
                      size: const Size(340, 340),
                      painter: _CountdownRingsPainter(
                        progress: animVal,
                        step: _currentCount,
                        isGo: _isGoState,
                      ),
                    ),

                    // Rotating Radial Progress Arc
                    Transform.rotate(
                      angle: animVal * 2 * math.pi,
                      child: Container(
                        width: ringRadius * 2,
                        height: ringRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (_isGoState
                                    ? AppColors.primaryTeal
                                    : AppColors.mint)
                                .withValues(
                                    alpha: (1.0 - animVal).clamp(0.1, 0.8)),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),

                    // Central Big Countdown Text / "GO!"
                    Transform.scale(
                      scale: numberScale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isGoState) ...[
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, AppColors.mint],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(
                                '$_currentCount',
                                style: const TextStyle(
                                  fontSize: 110,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -2,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _currentCount == 3
                                    ? 'GPS LOCKED 🛰️'
                                    : (_currentCount == 2
                                        ? 'SENSORS SYNCED 💓'
                                        : 'GET SET... 🔥'),
                                style: AppTypography.caption(
                                  color: AppColors.mint,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ] else ...[
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFE0FAF6),
                                  AppColors.primaryTeal,
                                  Color(0xFF4AC4B3)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
                                'GO!',
                                style: TextStyle(
                                  fontSize: 88,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'LAUNCHING RUN ⚡',
                              style: AppTypography.headingSmall(
                                color: Colors.white,
                              ).copyWith(
                                letterSpacing: 3,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // 4. Route Title Banner on Top
            Positioned(
              top: MediaQuery.of(context).padding.top + 36,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_run_rounded,
                          color: AppColors.mint,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.routeTitle ?? 'Starting Live Run Session',
                          style: AppTypography.bodySmall(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. Bottom Skip / Cancel Controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: widget.onCountdownComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      foregroundColor: AppColors.mint,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.mint.withValues(alpha: 0.4),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Skip Countdown'),
                        SizedBox(width: 6),
                        Icon(Icons.fast_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle Data Holder
class _WarpParticle {
  double angle;
  double radius;
  double speed;
  double size;
  Color color;

  _WarpParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.color,
  });
}

// Custom Painter for Warp Velocity Starfield
class _WarpStarfieldPainter extends CustomPainter {
  final List<_WarpParticle> particles;
  final double progress;
  final bool isGoState;

  _WarpStarfieldPainter({
    required this.particles,
    required this.progress,
    required this.isGoState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentRadius =
          (p.radius + (progress * p.speed * (isGoState ? 380 : 180))) %
              (size.width * 0.9);
      final currentAngle = p.angle;

      final x = center.dx + math.cos(currentAngle) * currentRadius;
      final y = center.dy + math.sin(currentAngle) * currentRadius;

      final alpha = (currentRadius / (size.width * 0.9)).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: alpha * 0.7);

      if (isGoState) {
        // Draw speed trail lines
        final trailLength = 12.0 * p.speed;
        final tx = x + math.cos(currentAngle) * trailLength;
        final ty = y + math.sin(currentAngle) * trailLength;
        final linePaint = Paint()
          ..color = p.color.withValues(alpha: alpha * 0.6)
          ..strokeWidth = p.size
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x, y), Offset(tx, ty), linePaint);
      } else {
        canvas.drawCircle(Offset(x, y), p.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WarpStarfieldPainter oldDelegate) => true;
}

// Custom Painter for Countdown Concentric Sonic Rings
class _CountdownRingsPainter extends CustomPainter {
  final double progress;
  final int step;
  final bool isGo;

  _CountdownRingsPainter({
    required this.progress,
    required this.step,
    required this.isGo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringColor = isGo ? AppColors.primaryTeal : AppColors.mint;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.25)) % 1.0;
      final radius = 70.0 + (ringProgress * 95.0);
      final alpha = (1.0 - ringProgress).clamp(0.0, 0.8) * 0.5;

      final paint = Paint()
        ..color = ringColor.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - ringProgress);

      canvas.drawCircle(center, radius, paint);
    }

    // Static dashed outer track
    final outerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 120, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _CountdownRingsPainter oldDelegate) => true;
}
