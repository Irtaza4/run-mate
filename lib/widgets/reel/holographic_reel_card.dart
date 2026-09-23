import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Available aesthetic visual themes for the 3D Holographic Reel Card
enum ReelCardTheme {
  cyberpunkNeon,
  mintAesthetic,
  sunsetGold,
  stealthTitanium,
}

/// A showstopping 3D Perspective Holographic Story Card featuring:
/// - True 3D Matrix4 perspective tilt with spring physics
/// - Iridescent rainbow holographic foil sheen & specular gleam
/// - Glowing Neon GPS Route Replay engine with comet sparks
/// - Real-time animated ECG heartbeat wave & metric badges
/// - Interactive confetti / particle blast cannon
class HolographicReelCard extends StatefulWidget {
  final RunActivity run;
  final ReelCardTheme theme;
  final bool autoTilt;
  final bool isStoryMode; // 9:16 vertical ratio for Reels / TikTok
  final double playbackSpeed;

  const HolographicReelCard({
    super.key,
    required this.run,
    this.theme = ReelCardTheme.cyberpunkNeon,
    this.autoTilt = true,
    this.isStoryMode = false,
    this.playbackSpeed = 1.0,
  });

  @override
  State<HolographicReelCard> createState() => HolographicReelCardState();
}

class HolographicReelCardState extends State<HolographicReelCard>
    with TickerProviderStateMixin {
  // 3D Tilt Controllers
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _isDragging = false;

  late AnimationController _autoTiltController;
  late AnimationController _shimmerController;
  late AnimationController _routeReplayController;
  late AnimationController _ecgController;
  late AnimationController _confettiController;

  final List<_ConfettiParticle> _confettiParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Auto-tilt subtle 3D floating wobble (perfect for Instagram reel screen recordings)
    _autoTiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Specular light sweep shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    // Continuous Neon Route Trace Replay (smooth loop)
    _routeReplayController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (6000 / widget.playbackSpeed).round()),
    )..repeat();

    // Live Heartbeat ECG Waveform
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Confetti Controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didUpdateWidget(covariant HolographicReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playbackSpeed != oldWidget.playbackSpeed) {
      _routeReplayController.duration =
          Duration(milliseconds: (6000 / widget.playbackSpeed).round());
      if (!_routeReplayController.isAnimating) {
        _routeReplayController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _autoTiltController.dispose();
    _shimmerController.dispose();
    _routeReplayController.dispose();
    _ecgController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Trigger celebratory explosive particle cannon
  void triggerConfettiBurst() {
    _confettiParticles.clear();
    final colors = [
      AppColors.mint,
      AppColors.primaryTeal,
      const Color(0xFFFF6B81),
      const Color(0xFFFFD166),
      const Color(0xFFC4B5FD),
      Colors.white,
    ];

    for (int i = 0; i < 60; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 120 + _random.nextDouble() * 240;
      _confettiParticles.add(
        _ConfettiParticle(
          x: 0,
          y: 0,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 60,
          size: 4 + _random.nextDouble() * 6,
          color: colors[_random.nextInt(colors.length)],
          rotationSpeed: (_random.nextDouble() - 0.5) * 12,
        ),
      );
    }

    _confettiController.forward(from: 0.0);
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _isDragging = true;
      // Convert drag delta to normalized tilt radians (-0.35 to 0.35 rad)
      _tiltY = (_tiltY + details.delta.dx * 0.004).clamp(-0.4, 0.4);
      _tiltX = (_tiltX - details.delta.dy * 0.004).clamp(-0.4, 0.4);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _autoTiltController,
        _shimmerController,
        _routeReplayController,
        _ecgController,
        _confettiController,
      ]),
      builder: (context, child) {
        // Compute effective 3D rotation angles
        double rotX = _tiltX;
        double rotY = _tiltY;

        if (widget.autoTilt && !_isDragging) {
          final autoVal = _autoTiltController.value * 2 * math.pi;
          rotX = math.sin(autoVal) * 0.08;
          rotY = math.cos(autoVal) * 0.12;
        }

        final themeColors = _getThemeTokens(widget.theme);

        return GestureDetector(
          onPanUpdate: (details) =>
              _onPanUpdate(details, MediaQuery.of(context).size),
          onPanEnd: _onPanEnd,
          onTap: triggerConfettiBurst,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Ambient Dynamic Card Drop Shadow & Neon Underglow
                Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateX(rotX * 0.6)
                    ..rotateY(rotY * 0.6),
                  child: Container(
                    width: widget.isStoryMode ? 330 : 350,
                    height: widget.isStoryMode ? 580 : 490,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: themeColors.accentColor.withValues(alpha: 0.35),
                          blurRadius: 36,
                          spreadRadius: 2,
                          offset: Offset(rotY * 40, 16 - rotX * 30),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. 3D Perspective Card Container
                Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateX(rotX)
                    ..rotateY(rotY),
                  child: Container(
                    width: widget.isStoryMode ? 330 : 350,
                    height: widget.isStoryMode ? 580 : 490,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: LinearGradient(
                        colors: themeColors.cardGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: themeColors.borderColor.withValues(alpha: 0.4),
                        width: 1.8,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Holographic Rainbow Foil Reflection Layer
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HolographicFoilPainter(
                              rotX: rotX,
                              rotY: rotY,
                              shimmerProgress: _shimmerController.value,
                              theme: widget.theme,
                            ),
                          ),
                        ),

                        // Card Content
                        Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Header: Branding & Achievement Badge
                              _buildCardHeader(run, themeColors),

                              const SizedBox(height: 16),

                              // Central Neon Route Replay Canvas
                              Expanded(
                                flex: widget.isStoryMode ? 4 : 3,
                                child: _buildNeonRouteReplayArea(
                                    run, themeColors),
                              ),

                              const SizedBox(height: 14),

                              // Animated Telemetry & Metrics HUD
                              _buildTelemetryGrid(run, themeColors),

                              if (widget.isStoryMode) ...[
                                const SizedBox(height: 14),
                                _buildStoryFooter(themeColors),
                              ],
                            ],
                          ),
                        ),

                        // Specular Rim Light Gleam
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  themeColors.accentColor
                                      .withValues(alpha: 0.9),
                                  Colors.white,
                                  themeColors.accentColor
                                      .withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Floating Confetti Particle Overlay
                if (_confettiController.isAnimating)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ConfettiPainter(
                          particles: _confettiParticles,
                          progress: _confettiController.value,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Top Card Header ---
  Widget _buildCardHeader(RunActivity run, _ThemeTokens theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  color: theme.accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RUNMATE PRO',
                      style: AppTypography.caption(
                        color: theme.accentColor,
                        fontWeight: FontWeight.w800,
                      ).copyWith(letterSpacing: 1.5, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      run.title,
                      style: AppTypography.headingSmall(
                        color: Colors.white,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Shiny Holographic Trophy Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.35),
                theme.secondaryAccent.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Text(
                'RECORD',
                style: AppTypography.caption(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ).copyWith(fontSize: 9, letterSpacing: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Neon Route Replay Canvas ---
  Widget _buildNeonRouteReplayArea(RunActivity run, _ThemeTokens theme) {
    final coords = run.routeCoordinates.isNotEmpty
        ? run.routeCoordinates
        : const [
            Offset(0.15, 0.75),
            Offset(0.32, 0.48),
            Offset(0.55, 0.62),
            Offset(0.72, 0.38),
            Offset(0.85, 0.22),
          ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background City Grid Lines
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(gridColor: theme.gridColor),
            ),
          ),

          // Neon Route Trace with Moving Laser Comet
          Positioned.fill(
            child: CustomPaint(
              painter: _NeonRouteReplayPainter(
                route: coords,
                progress: _routeReplayController.value,
                accentColor: theme.accentColor,
                trailColor: theme.secondaryAccent,
              ),
            ),
          ),

          // Top Live Pace Overlay Ribbon
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REPLAY: ${(_routeReplayController.value * 100).toInt()}%',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Live Animated Telemetry HUD ---
  Widget _buildTelemetryGrid(RunActivity run, _ThemeTokens theme) {
    return Column(
      children: [
        // Primary Big Stats: Distance & Duration
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'DISTANCE',
                value: run.distanceKm.toStringAsFixed(2),
                unit: 'KM',
                icon: Icons.straighten_rounded,
                theme: theme,
                highlight: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                label: 'PACE',
                value: run.formattedPace,
                unit: '/KM',
                icon: Icons.speed_rounded,
                theme: theme,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Secondary Stats: Calories & Heart Rate with Animated Wave
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                label: 'CALORIES',
                value: '${run.calories}',
                unit: 'KCAL',
                icon: Icons.local_fire_department_rounded,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildHeartRateMetricTile(run, theme),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required _ThemeTokens theme,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? theme.accentColor.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? theme.accentColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: highlight ? theme.accentColor : Colors.white60,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption(
                  color: highlight ? theme.accentColor : Colors.white60,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 9, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: AppTypography.headingLarge(
                      color: Colors.white,
                    ).copyWith(
                      fontSize: highlight ? 22 : 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: AppTypography.caption(
                  color: highlight ? theme.accentColor : Colors.white60,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateMetricTile(RunActivity run, _ThemeTokens theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 12,
                    color: Color(0xFFFF5E7E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AVG BPM',
                    style: AppTypography.caption(
                      color: Colors.white60,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 9),
                  ),
                ],
              ),
              // Live ECG Pulse Mini Line
              SizedBox(
                width: 24,
                height: 12,
                child: CustomPaint(
                  painter: _MiniEcgPainter(
                    progress: _ecgController.value,
                    color: const Color(0xFFFF5E7E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${run.avgHeartRate}',
                    style: AppTypography.headingLarge(
                      color: Colors.white,
                    ).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Text(
                'BPM',
                style: AppTypography.caption(
                  color: const Color(0xFFFF5E7E),
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoryFooter(_ThemeTokens theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Text(
        '#RunMateApp • #RunnersOfInstagram',
        style: TextStyle(
          color: theme.accentColor.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // --- Theme Token Helper ---
  _ThemeTokens _getThemeTokens(ReelCardTheme theme) {
    switch (theme) {
      case ReelCardTheme.cyberpunkNeon:
        return _ThemeTokens(
          cardGradient: [
            const Color(0xFF0F121C),
            const Color(0xFF090A10),
          ],
          accentColor: AppColors.primaryTeal,
          secondaryAccent: const Color(0xFFA78BFA),
          borderColor: AppColors.primaryTeal,
          gridColor: const Color(0xFF1E293B),
        );
      case ReelCardTheme.mintAesthetic:
        return _ThemeTokens(
          cardGradient: [
            const Color(0xFF152220),
            const Color(0xFF0D1615),
          ],
          accentColor: AppColors.mint,
          secondaryAccent: AppColors.primaryTeal,
          borderColor: AppColors.mint,
          gridColor: const Color(0xFF1C2F2B),
        );
      case ReelCardTheme.sunsetGold:
        return _ThemeTokens(
          cardGradient: [
            const Color(0xFF221313),
            const Color(0xFF140B0B),
          ],
          accentColor: const Color(0xFFFFB03A),
          secondaryAccent: const Color(0xFFFF4848),
          borderColor: const Color(0xFFFFB03A),
          gridColor: const Color(0xFF331E1E),
        );
      case ReelCardTheme.stealthTitanium:
        return _ThemeTokens(
          cardGradient: [
            const Color(0xFF1E2124),
            const Color(0xFF111215),
          ],
          accentColor: const Color(0xFF38BDF8),
          secondaryAccent: const Color(0xFF818CF8),
          borderColor: const Color(0xFF475569),
          gridColor: const Color(0xFF2B3037),
        );
    }
  }
}

class _ThemeTokens {
  final List<Color> cardGradient;
  final Color accentColor;
  final Color secondaryAccent;
  final Color borderColor;
  final Color gridColor;

  _ThemeTokens({
    required this.cardGradient,
    required this.accentColor,
    required this.secondaryAccent,
    required this.borderColor,
    required this.gridColor,
  });
}

// Painter for Holographic Rainbow Iridescent Foil
class _HolographicFoilPainter extends CustomPainter {
  final double rotX;
  final double rotY;
  final double shimmerProgress;
  final ReelCardTheme theme;

  _HolographicFoilPainter({
    required this.rotX,
    required this.rotY,
    required this.shimmerProgress,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Foil angle shifts with 3D tilt
    final sweepAngle = (shimmerProgress * 2 * math.pi) + (rotY * 4.0);
    final center = Offset(size.width * 0.5, size.height * 0.5);

    final foilShader = ui.Gradient.linear(
      Offset(
        center.dx + math.cos(sweepAngle) * size.width * 0.7,
        center.dy + math.sin(sweepAngle) * size.height * 0.7,
      ),
      Offset(
        center.dx - math.cos(sweepAngle) * size.width * 0.7,
        center.dy - math.sin(sweepAngle) * size.height * 0.7,
      ),
      [
        Colors.transparent,
        const Color(0xFF80FFDB).withValues(alpha: 0.08),
        const Color(0xFFFFB4D6).withValues(alpha: 0.12),
        const Color(0xFF72EFDD).withValues(alpha: 0.10),
        const Color(0xFFFFD166).withValues(alpha: 0.08),
        Colors.transparent,
      ],
      [0.0, 0.25, 0.5, 0.75, 0.9, 1.0],
    );

    final paint = Paint()
      ..shader = foilShader
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _HolographicFoilPainter oldDelegate) => true;
}

// Background Grid Painter for Neon Map Canvas
class _CyberGridPainter extends CustomPainter {
  final Color gridColor;

  _CyberGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    const spacing = 26.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) => false;
}

// Painter for Neon GPS Route Replay with Laser Comet Head
class _NeonRouteReplayPainter extends CustomPainter {
  final List<Offset> route;
  final double progress;
  final Color accentColor;
  final Color trailColor;

  _NeonRouteReplayPainter({
    required this.route,
    required this.progress,
    required this.accentColor,
    required this.trailColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (route.length < 2) return;

    final points = route
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    // 1. Draw static full route baseline (dim)
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fullPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fullPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(fullPath, basePaint);

    // Compute active progress along path
    final totalSegments = points.length - 1;
    final progressScaled = (progress * totalSegments).clamp(0.0, totalSegments.toDouble());
    final currentSegmentIndex = progressScaled.floor().clamp(0, totalSegments - 1);
    final segmentProgress = progressScaled - currentSegmentIndex;

    final activePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i <= currentSegmentIndex; i++) {
      activePath.lineTo(points[i].dx, points[i].dy);
    }

    final currentP1 = points[currentSegmentIndex];
    final currentP2 = points[currentSegmentIndex + 1];
    final currentHead = Offset(
      currentP1.dx + (currentP2.dx - currentP1.dx) * segmentProgress,
      currentP1.dy + (currentP2.dy - currentP1.dy) * segmentProgress,
    );
    activePath.lineTo(currentHead.dx, currentHead.dy);

    // 2. Glowing Neon Polyline Trail
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(activePath, glowPaint);

    final corePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(activePath, corePaint);

    // 3. Start Marker (Green Ring)
    final startPaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(points.first, 5, startPaint);
    canvas.drawCircle(
      points.first,
      8,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4. Moving Laser Comet Head
    final cometAura = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(currentHead, 7, cometAura);

    final cometCore = Paint()..color = accentColor;
    canvas.drawCircle(currentHead, 4.5, cometCore);

    final cometWhiteCenter = Paint()..color = Colors.white;
    canvas.drawCircle(currentHead, 2, cometWhiteCenter);
  }

  @override
  bool shouldRepaint(covariant _NeonRouteReplayPainter oldDelegate) => true;
}

// Mini ECG Waveform Painter
class _MiniEcgPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniEcgPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.3, h * 0.5);
    // QRS spike
    final spikeOffset = math.sin(progress * 2 * math.pi) * (h * 0.4);
    path.lineTo(w * 0.45, h * 0.5 - spikeOffset);
    path.lineTo(w * 0.6, h * 0.5 + spikeOffset * 0.8);
    path.lineTo(w * 0.75, h * 0.5);
    path.lineTo(w, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniEcgPainter oldDelegate) => true;
}

// Confetti Particle & Painter
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final curX = center.dx + p.x + (p.vx * progress);
      // Gravity deceleration
      final curY = center.dy + p.y + (p.vy * progress) + (240 * progress * progress);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = p.color.withValues(alpha: alpha);

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(p.rotationSpeed * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
