import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Quiet, stylized vector map canvas rendering routes and live runner telemetry
class RouteMapView extends StatefulWidget {
  final List<Offset> routeCoordinates;
  final Offset? runnerPosition;
  final bool isLive;
  final bool showControls;
  final double height;
  final VoidCallback? onRecenter;

  const RouteMapView({
    super.key,
    required this.routeCoordinates,
    this.runnerPosition,
    this.isLive = false,
    this.showControls = false,
    this.height = 280,
    this.onRecenter,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151818) : const Color(0xFFEAEFEF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Quiet Vector Map & Polyline Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _QuietMapPainter(
                    routePoints: widget.routeCoordinates,
                    runnerPoint: widget.runnerPosition ??
                        (widget.routeCoordinates.isNotEmpty
                            ? widget.routeCoordinates.last
                            : null),
                    pulseValue: _pulseController.value,
                    isDark: isDark,
                    zoomLevel: _zoomLevel,
                  ),
                );
              },
            ),
          ),

          // Map Control Floating Buttons (if enabled)
          if (widget.showControls)
            Positioned(
              right: 14,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMapControlButton(
                    icon: Icons.add_rounded,
                    onTap: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 2.0);
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 2.0);
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    icon: Icons.my_location_rounded,
                    iconColor: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                    onTap: () {
                      setState(() {
                        _zoomLevel = 1.0;
                      });
                      widget.onRecenter?.call();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? (isDark ? Colors.white : AppColors.primaryText),
        ),
      ),
    );
  }
}

class _QuietMapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final Offset? runnerPoint;
  final double pulseValue;
  final bool isDark;
  final double zoomLevel;

  _QuietMapPainter({
    required this.routePoints,
    required this.runnerPoint,
    required this.pulseValue,
    required this.isDark,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle ambient background features (River / Green zones)
    _drawLandscape(canvas, size);

    // 2. Draw quiet road grid network
    _drawRoadGrid(canvas, size);

    // 3. Draw route path
    if (routePoints.length > 1) {
      _drawRoutePolyline(canvas, size);
    }

    // 4. Draw start point pin
    if (routePoints.isNotEmpty) {
      final startPos = _toPixel(routePoints.first, size);
      _drawStartPin(canvas, startPos);
    }

    // 5. Draw active runner marker with pulse
    if (runnerPoint != null) {
      final currentPos = _toPixel(runnerPoint!, size);
      _drawRunnerMarker(canvas, currentPos);
    }
  }

  Offset _toPixel(Offset normalized, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final px = normalized.dx * size.width;
    final py = normalized.dy * size.height;
    return Offset(
      centerX + (px - centerX) * zoomLevel,
      centerY + (py - centerY) * zoomLevel,
    );
  }

  void _drawLandscape(Canvas canvas, Size size) {
    // Soft water path / river
    final riverPaint = Paint()
      ..color = isDark
          ? const Color(0xFF102224).withValues(alpha: 0.7)
          : const Color(0xFFD6EAE7)
      ..style = PaintingStyle.fill;

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.25);
    riverPath.cubicTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.65,
      size.height * 0.45,
      size.width,
      size.height * 0.35,
    );
    riverPath.lineTo(size.width, size.height * 0.52);
    riverPath.cubicTo(
      size.width * 0.65,
      size.height * 0.62,
      size.width * 0.35,
      size.height * 0.32,
      0,
      size.height * 0.42,
    );
    riverPath.close();
    canvas.drawPath(riverPath, riverPaint);

    // Soft park zone
    final parkPaint = Paint()
      ..color = isDark
          ? const Color(0xFF16251E).withValues(alpha: 0.5)
          : const Color(0xFFE2F0EA)
      ..style = PaintingStyle.fill;

    final parkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.55,
        size.height * 0.62,
        size.width * 0.38,
        size.height * 0.28,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(parkRect, parkPaint);
  }

  void _drawRoadGrid(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isDark
          ? const Color(0xFF222828).withValues(alpha: 0.8)
          : const Color(0xFFDCE2E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1B2020).withValues(alpha: 0.6)
          : const Color(0xFFE5ECEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Horizontal street lines
    for (double y = 0.15; y <= 0.95; y += 0.20) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        minorRoadPaint,
      );
    }

    // Vertical avenues
    for (double x = 0.20; x <= 0.90; x += 0.25) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        minorRoadPaint,
      );
    }

    // Main thoroughfare
    final mainRoadPath = Path();
    mainRoadPath.moveTo(size.width * 0.05, size.height * 0.88);
    mainRoadPath.cubicTo(
      size.width * 0.30,
      size.height * 0.70,
      size.width * 0.70,
      size.height * 0.85,
      size.width * 0.95,
      size.height * 0.15,
    );
    canvas.drawPath(mainRoadPath, roadPaint);
  }

  void _drawRoutePolyline(Canvas canvas, Size size) {
    final path = Path();
    final firstPoint = _toPixel(routePoints.first, size);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < routePoints.length; i++) {
      final p = _toPixel(routePoints[i], size);
      path.lineTo(p.dx, p.dy);
    }

    // Glow shadow
    final glowPaint = Paint()
      ..color = AppColors.primaryTeal.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Primary route line
    final routePaint = Paint()
      ..color = isDark ? AppColors.darkMint : AppColors.primaryTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, routePaint);
  }

  void _drawStartPin(Canvas canvas, Offset pos) {
    // Outer white halo
    canvas.drawCircle(
      pos,
      8,
      Paint()..color = Colors.white,
    );
    // Inner dark/teal dot
    canvas.drawCircle(
      pos,
      5,
      Paint()..color = isDark ? AppColors.darkMint : AppColors.darkNavigation,
    );
  }

  void _drawRunnerMarker(Canvas canvas, Offset pos) {
    // Pulsing radar ripple
    final rippleRadius = 10.0 + (pulseValue * 18.0);
    final rippleAlpha = (1.0 - pulseValue) * 0.45;
    final ripplePaint = Paint()
      ..color = AppColors.primaryTeal.withValues(alpha: rippleAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, rippleRadius, ripplePaint);

    // Outer shadow
    canvas.drawCircle(
      pos,
      12,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Core white badge
    canvas.drawCircle(
      pos,
      10,
      Paint()..color = Colors.white,
    );

    // Center teal circle
    canvas.drawCircle(
      pos,
      6.5,
      Paint()..color = isDark ? AppColors.darkMint : AppColors.primaryTeal,
    );
  }

  @override
  bool shouldRepaint(covariant _QuietMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.runnerPoint != runnerPoint ||
        oldDelegate.routePoints != routePoints ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.isDark != isDark;
  }
}
