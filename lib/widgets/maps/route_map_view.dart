import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Highly stylized, interactive simulated (fake) vector map canvas
/// rendering realistic city blocks, waterways, parks, street labels,
/// route polylines, split markers, and pulsing live runner telemetry.
class RouteMapView extends StatefulWidget {
  final List<Offset> routeCoordinates;
  final Offset? runnerPosition;
  final bool isLive;
  final bool showControls;
  final double height;
  final VoidCallback? onRecenter;
  final bool enableGestures;

  const RouteMapView({
    super.key,
    required this.routeCoordinates,
    this.runnerPosition,
    this.isLive = false,
    this.showControls = false,
    this.height = 280,
    this.onRecenter,
    this.enableGestures = true,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _runProgressController;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _lastZoom = 1.0;

  @override
  void initState() {
    super.initState();
    // Sonar radar & footstep pulse (natural running cadence)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // 60FPS smooth continuous running progress at a realistic pace (90 seconds circuit)
    _runProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    );

    if (widget.isLive) {
      _runProgressController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive && !_runProgressController.isAnimating) {
      _runProgressController.repeat();
    } else if (!widget.isLive && _runProgressController.isAnimating) {
      _runProgressController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _runProgressController.dispose();
    super.dispose();
  }

  void _resetView() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
    });
    widget.onRecenter?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101414) : const Color(0xFFEAF0F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // 1. Interactive Gestures Canvas for Pan & Zoom
          GestureDetector(
            onScaleStart: widget.enableGestures
                ? (details) {
                    _lastFocalPoint = details.focalPoint;
                    _lastZoom = _zoomLevel;
                  }
                : null,
            onScaleUpdate: widget.enableGestures
                ? (details) {
                    setState(() {
                      final delta = details.focalPoint - _lastFocalPoint;
                      _lastFocalPoint = details.focalPoint;
                      _panOffset += delta;
                      _zoomLevel =
                          (_lastZoom * details.scale).clamp(0.65, 3.0);
                    });
                  }
                : null,
            onDoubleTap: widget.enableGestures
                ? () {
                    setState(() {
                      _zoomLevel = _zoomLevel > 1.2 ? 1.0 : 1.6;
                      _panOffset = Offset.zero;
                    });
                  }
                : null,
            child: SizedBox.expand(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseController, _runProgressController]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FakeVectorMapPainter(
                      routePoints: widget.routeCoordinates,
                      runnerPoint: widget.runnerPosition,
                      pulseValue: _pulseController.value,
                      runProgress: widget.isLive ? _runProgressController.value : 1.0,
                      isDark: isDark,
                      zoomLevel: _zoomLevel,
                      panOffset: _panOffset,
                      isLive: widget.isLive,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Minimalist Compass Badge (Top Left)
          if (widget.showControls)
            Positioned(
              top: 14,
              left: 14,
              child: _buildCompassBadge(isDark),
            ),

          // 3. Simulated Map Mode Pill (Top Right)
          if (widget.showControls)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.65)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.isLive ? 'LIVE GPS SIM' : 'MAP PREVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white70 : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Map Control Floating Action Buttons (Bottom Right)
          if (widget.showControls)
            Positioned(
              right: 14,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMapControlButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Zoom In',
                    onTap: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 0.25).clamp(0.65, 3.0);
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Zoom Out',
                    onTap: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 0.25).clamp(0.65, 3.0);
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildMapControlButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter',
                    iconColor:
                        isDark ? AppColors.darkMint : AppColors.primaryTeal,
                    onTap: _resetView,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompassBadge(bool isDark) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? AppColors.darkDivider
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.navigation_rounded,
            size: 14,
            color: AppColors.danger,
          ),
          Text(
            'N',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.primaryText,
              height: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? iconColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E2525).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
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

/// Custom vector map painter providing an authentic city topography:
/// river, city blocks, multi-tier roads, park nature reserves, POIs, street names,
/// route polylines, start/finish flags, km split pins, and runner radar.
class _FakeVectorMapPainter extends CustomPainter {
  final List<Offset> routePoints;
  final Offset? runnerPoint;
  final double pulseValue;
  final double runProgress; // Continuous 0.0 -> 1.0 running progress along spline
  final bool isDark;
  final double zoomLevel;
  final Offset panOffset;
  final bool isLive;

  _FakeVectorMapPainter({
    required this.routePoints,
    required this.runnerPoint,
    required this.pulseValue,
    required this.runProgress,
    required this.isDark,
    required this.zoomLevel,
    required this.panOffset,
    required this.isLive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // 1. City Blocks / Urban Lots (Background layer)
    _drawCityBlocks(canvas, size);

    // 2. Natural Waterways (River & Shoreline)
    _drawRiverAndWater(canvas, size);

    // 3. Parks, Woodlands & Green Belts
    _drawParkReserves(canvas, size);

    // 4. City Road Network (Avenues, Streets, Trails, Bridges)
    _drawRoadNetwork(canvas, size);

    // 5. Street Names & POI Labels
    _drawLabelsAndLandmarks(canvas, size);

    // 6. Calculate continuous runner position, heading angle, and split route
    final runnerState = _calculateRunnerSplineState(size);

    // 7. Running Route Polylines (Completed Track vs Upcoming Track)
    if (routePoints.length > 1) {
      _drawRoutePolylines(
        canvas: canvas,
        size: size,
        completedPoints: runnerState.completedPixels,
        upcomingPoints: runnerState.upcomingPixels,
      );
    }

    // 8. Kilometer Split Badges
    if (routePoints.length > 2) {
      _drawKmSplitBadges(canvas, size);
    }

    // 9. Start Pin & Finish Flag
    if (routePoints.isNotEmpty) {
      final startPos = _toPixel(routePoints.first, size);
      _drawStartMarker(canvas, startPos);

      if (!isLive && routePoints.length > 3) {
        final endPos = _toPixel(routePoints.last, size);
        _drawFinishMarker(canvas, endPos);
      }
    }

    // 10. Active Live Runner Radar Beacon, Stride Ripples & Heading Arrow
    _drawRunnerMarker(
      canvas: canvas,
      pos: runnerState.pixelPos,
      headingAngle: runnerState.headingAngle,
    );

    canvas.restore();
  }

  // Calculates continuous runner position, heading tangent, and route segment split
  ({Offset pixelPos, double headingAngle, List<Offset> completedPixels, List<Offset> upcomingPixels})
      _calculateRunnerSplineState(Size size) {
    if (routePoints.isEmpty) {
      return (
        pixelPos: _toPixel(const Offset(0.5, 0.5), size),
        headingAngle: 0.0,
        completedPixels: <Offset>[],
        upcomingPixels: <Offset>[],
      );
    }

    final pixelPoints = routePoints.map((p) => _toPixel(p, size)).toList();
    if (pixelPoints.length == 1) {
      return (
        pixelPos: pixelPoints.first,
        headingAngle: 0.0,
        completedPixels: pixelPoints,
        upcomingPixels: <Offset>[],
      );
    }

    // Calculate cumulative distances along polyline
    final List<double> segmentLengths = [];
    double totalLength = 0.0;
    for (int i = 1; i < pixelPoints.length; i++) {
      final d = (pixelPoints[i] - pixelPoints[i - 1]).distance;
      segmentLengths.add(d);
      totalLength += d;
    }

    final progress = runProgress.clamp(0.0, 1.0);
    final targetDistance = progress * totalLength;

    double accumulated = 0.0;
    Offset currentPos = pixelPoints.first;
    double heading = 0.0;
    int currentSegIndex = 0;

    final List<Offset> completed = [pixelPoints.first];
    final List<Offset> upcoming = [];

    for (int i = 0; i < segmentLengths.length; i++) {
      final segLen = segmentLengths[i];
      final p1 = pixelPoints[i];
      final p2 = pixelPoints[i + 1];

      if (accumulated + segLen >= targetDistance) {
        final segProgress = segLen > 0 ? (targetDistance - accumulated) / segLen : 0.0;
        currentPos = Offset(
          p1.dx + (p2.dx - p1.dx) * segProgress,
          p1.dy + (p2.dy - p1.dy) * segProgress,
        );
        heading = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
        completed.add(currentPos);
        upcoming.add(currentPos);
        currentSegIndex = i + 1;
        break;
      } else {
        accumulated += segLen;
        completed.add(p2);
      }
    }

    for (int i = currentSegIndex; i < pixelPoints.length; i++) {
      upcoming.add(pixelPoints[i]);
    }

    return (
      pixelPos: currentPos,
      headingAngle: heading,
      completedPixels: completed,
      upcomingPixels: upcoming,
    );
  }

  Offset _toPixel(Offset normalized, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final px = normalized.dx * size.width;
    final py = normalized.dy * size.height;
    return Offset(
      centerX + (px - centerX) * zoomLevel + panOffset.dx,
      centerY + (py - centerY) * zoomLevel + panOffset.dy,
    );
  }

  void _drawCityBlocks(Canvas canvas, Size size) {
    final blockFill = Paint()
      ..color = isDark ? const Color(0xFF161B1B) : const Color(0xFFE2E9E9)
      ..style = PaintingStyle.fill;

    final blockBorder = Paint()
      ..color = isDark
          ? const Color(0xFF1E2424).withValues(alpha: 0.6)
          : const Color(0xFFD4DEDE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Grid of realistic city parcels / building footprints
    final blockOffsets = [
      // Top Left quadrant
      const Rect.fromLTWH(0.04, 0.05, 0.12, 0.12),
      const Rect.fromLTWH(0.18, 0.05, 0.14, 0.08),
      const Rect.fromLTWH(0.04, 0.20, 0.10, 0.14),
      const Rect.fromLTWH(0.16, 0.15, 0.16, 0.12),

      // Center North
      const Rect.fromLTWH(0.38, 0.04, 0.14, 0.10),
      const Rect.fromLTWH(0.54, 0.04, 0.18, 0.14),
      const Rect.fromLTWH(0.74, 0.05, 0.20, 0.10),
      const Rect.fromLTWH(0.74, 0.18, 0.18, 0.14),

      // Center East
      const Rect.fromLTWH(0.70, 0.36, 0.24, 0.12),
      const Rect.fromLTWH(0.75, 0.52, 0.19, 0.16),

      // Center South
      const Rect.fromLTWH(0.05, 0.58, 0.16, 0.18),
      const Rect.fromLTWH(0.24, 0.64, 0.14, 0.15),
      const Rect.fromLTWH(0.05, 0.79, 0.18, 0.16),
      const Rect.fromLTWH(0.25, 0.82, 0.16, 0.14),
      const Rect.fromLTWH(0.44, 0.78, 0.20, 0.16),
      const Rect.fromLTWH(0.68, 0.75, 0.26, 0.18),
    ];

    for (final rect in blockOffsets) {
      final p1 = _toPixel(rect.topLeft, size);
      final p2 = _toPixel(rect.bottomRight, size);
      final screenRect = Rect.fromPoints(p1, p2);
      final rrect = RRect.fromRectAndRadius(screenRect, const Radius.circular(8));
      canvas.drawRRect(rrect, blockFill);
      canvas.drawRRect(rrect, blockBorder);
    }
  }

  void _drawRiverAndWater(Canvas canvas, Size size) {
    // Water surface
    final riverPaint = Paint()
      ..color = isDark
          ? const Color(0xFF0D2529).withValues(alpha: 0.9)
          : const Color(0xFFCCE4E2)
      ..style = PaintingStyle.fill;

    // Water shoreline casing
    final shorePaint = Paint()
      ..color = isDark
          ? const Color(0xFF13363B).withValues(alpha: 0.7)
          : const Color(0xFFB4D7D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pStart = _toPixel(const Offset(-0.1, 0.30), size);
    final pC1 = _toPixel(const Offset(0.30, 0.20), size);
    final pC2 = _toPixel(const Offset(0.60, 0.48), size);
    final pEnd = _toPixel(const Offset(1.15, 0.36), size);

    final pEnd2 = _toPixel(const Offset(1.15, 0.54), size);
    final pC3 = _toPixel(const Offset(0.60, 0.66), size);
    final pC4 = _toPixel(const Offset(0.30, 0.38), size);
    final pStart2 = _toPixel(const Offset(-0.1, 0.48), size);

    final riverPath = Path()
      ..moveTo(pStart.dx, pStart.dy)
      ..cubicTo(pC1.dx, pC1.dy, pC2.dx, pC2.dy, pEnd.dx, pEnd.dy)
      ..lineTo(pEnd2.dx, pEnd2.dy)
      ..cubicTo(pC3.dx, pC3.dy, pC4.dx, pC4.dy, pStart2.dx, pStart2.dy)
      ..close();

    canvas.drawPath(riverPath, riverPaint);
    canvas.drawPath(riverPath, shorePaint);

    // River Island / Delta
    final islandCenter = _toPixel(const Offset(0.48, 0.38), size);
    final islandRadius = 14 * zoomLevel;
    final islandPaint = Paint()
      ..color = isDark ? const Color(0xFF16251E) : const Color(0xFFDCEDE5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(islandCenter, islandRadius, islandPaint);
  }

  void _drawParkReserves(Canvas canvas, Size size) {
    final parkPaint = Paint()
      ..color = isDark
          ? const Color(0xFF152A20).withValues(alpha: 0.75)
          : const Color(0xFFD8EDE2)
      ..style = PaintingStyle.fill;

    final parkBorder = Paint()
      ..color = isDark
          ? const Color(0xFF1C3A2C).withValues(alpha: 0.6)
          : const Color(0xFFC0E2CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Main Riverside Park
    final p1 = _toPixel(const Offset(0.42, 0.50), size);
    final p2 = _toPixel(const Offset(0.85, 0.72), size);
    final parkRRect = RRect.fromRectAndRadius(
      Rect.fromPoints(p1, p2),
      Radius.circular(18 * zoomLevel),
    );
    canvas.drawRRect(parkRRect, parkPaint);
    canvas.drawRRect(parkRRect, parkBorder);

    // Secondary North Park
    final np1 = _toPixel(const Offset(0.04, 0.04), size);
    final np2 = _toPixel(const Offset(0.32, 0.18), size);
    final northParkRRect = RRect.fromRectAndRadius(
      Rect.fromPoints(np1, np2),
      Radius.circular(14 * zoomLevel),
    );
    canvas.drawRRect(northParkRRect, parkPaint);
    canvas.drawRRect(northParkRRect, parkBorder);

    // Little decorative botanical trees
    _drawTreeIcon(canvas, _toPixel(const Offset(0.52, 0.56), size));
    _drawTreeIcon(canvas, _toPixel(const Offset(0.68, 0.62), size));
    _drawTreeIcon(canvas, _toPixel(const Offset(0.78, 0.58), size));
    _drawTreeIcon(canvas, _toPixel(const Offset(0.12, 0.10), size));
    _drawTreeIcon(canvas, _toPixel(const Offset(0.22, 0.12), size));
  }

  void _drawTreeIcon(Canvas canvas, Offset pos) {
    final treePaint = Paint()
      ..color = isDark
          ? const Color(0xFF22523A).withValues(alpha: 0.8)
          : const Color(0xFFA6D6BC)
      ..style = PaintingStyle.fill;
    final r = 5.0 * zoomLevel;
    canvas.drawCircle(pos, r, treePaint);
  }

  void _drawRoadNetwork(Canvas canvas, Size size) {
    // 1. Minor Streets (Thin grid lines)
    final minorStreetPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1B2222).withValues(alpha: 0.75)
          : const Color(0xFFDFE6E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.5 * zoomLevel).clamp(1.0, 3.0);

    // Horizontal streets
    final yCoords = [0.12, 0.28, 0.44, 0.60, 0.76, 0.92];
    for (final y in yCoords) {
      final start = _toPixel(Offset(-0.1, y), size);
      final end = _toPixel(Offset(1.1, y), size);
      canvas.drawLine(start, end, minorStreetPaint);
    }

    // Vertical avenues
    final xCoords = [0.15, 0.35, 0.55, 0.75, 0.92];
    for (final x in xCoords) {
      final start = _toPixel(Offset(x, -0.1), size);
      final end = _toPixel(Offset(x, 1.1), size);
      canvas.drawLine(start, end, minorStreetPaint);
    }

    // 2. Meandering Park Trail (Dashed Green Path)
    final trailPaint = Paint()
      ..color = isDark
          ? const Color(0xFF2A5540).withValues(alpha: 0.85)
          : const Color(0xFF7EBA9C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (2.0 * zoomLevel).clamp(1.5, 4.0);

    final trailPath = Path();
    final tp0 = _toPixel(const Offset(0.44, 0.54), size);
    final tp1 = _toPixel(const Offset(0.60, 0.52), size);
    final tp2 = _toPixel(const Offset(0.72, 0.65), size);
    final tp3 = _toPixel(const Offset(0.82, 0.68), size);
    trailPath.moveTo(tp0.dx, tp0.dy);
    trailPath.cubicTo(tp1.dx, tp1.dy, tp2.dx, tp2.dy, tp3.dx, tp3.dy);
    canvas.drawPath(trailPath, trailPaint);

    // 3. Primary Arterial Boulevard (Thick double casing + fill)
    final roadCasing = Paint()
      ..color = isDark
          ? const Color(0xFF2B3333)
          : const Color(0xFFCAD4D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (6.0 * zoomLevel).clamp(4.0, 12.0)
      ..strokeCap = StrokeCap.round;

    final roadCore = Paint()
      ..color = isDark
          ? const Color(0xFF1E2626)
          : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = (4.0 * zoomLevel).clamp(2.5, 9.0)
      ..strokeCap = StrokeCap.round;

    final mainRoadPath = Path();
    final p0 = _toPixel(const Offset(-0.05, 0.85), size);
    final p1 = _toPixel(const Offset(0.28, 0.70), size);
    final p2 = _toPixel(const Offset(0.68, 0.88), size);
    final p3 = _toPixel(const Offset(1.05, 0.15), size);

    mainRoadPath.moveTo(p0.dx, p0.dy);
    mainRoadPath.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    canvas.drawPath(mainRoadPath, roadCasing);
    canvas.drawPath(mainRoadPath, roadCore);

    // Bridge Deck Over River Crossing
    final bridgeDeckPos = _toPixel(const Offset(0.88, 0.44), size);
    final bridgeRect = Rect.fromCenter(
      center: bridgeDeckPos,
      width: 14 * zoomLevel,
      height: 8 * zoomLevel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeRect, const Radius.circular(2)),
      roadCasing,
    );
  }

  void _drawLabelsAndLandmarks(Canvas canvas, Size size) {
    if (zoomLevel < 0.75) return; // Keep clean at small scale

    // Street Name Labels
    _drawTextLabel(
      canvas: canvas,
      text: 'RIVERSIDE BLVD',
      position: _toPixel(const Offset(0.50, 0.26), size),
      fontSize: 8.5 * zoomLevel.clamp(0.8, 1.3),
      isDark: isDark,
      isStreet: true,
    );

    _drawTextLabel(
      canvas: canvas,
      text: 'GRAND PARKWAY',
      position: _toPixel(const Offset(0.46, 0.74), size),
      fontSize: 8.5 * zoomLevel.clamp(0.8, 1.3),
      isDark: isDark,
      isStreet: true,
    );

    _drawTextLabel(
      canvas: canvas,
      text: '5TH AVE',
      position: _toPixel(const Offset(0.35, 0.10), size),
      fontSize: 8.0 * zoomLevel.clamp(0.8, 1.2),
      isDark: isDark,
      isStreet: true,
    );

    // Landmark POIs
    _drawPoiBadge(
      canvas: canvas,
      icon: '🌳',
      name: 'Central Green',
      position: _toPixel(const Offset(0.62, 0.58), size),
      isDark: isDark,
    );

    _drawPoiBadge(
      canvas: canvas,
      icon: '☕',
      name: 'River Cafe',
      position: _toPixel(const Offset(0.24, 0.60), size),
      isDark: isDark,
    );
  }

  void _drawTextLabel({
    required Canvas canvas,
    required String text,
    required Offset position,
    required double fontSize,
    required bool isDark,
    bool isStreet = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isDark
            ? (isStreet ? const Color(0xFF5A6E6E) : Colors.white70)
            : (isStreet ? const Color(0xFF8A9A9A) : AppColors.primaryText),
        fontSize: fontSize.clamp(7.0, 13.0),
        fontWeight: FontWeight.w700,
        letterSpacing: isStreet ? 1.2 : 0.4,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy - tp.height / 2));
  }

  void _drawPoiBadge({
    required Canvas canvas,
    required String icon,
    required String name,
    required Offset position,
    required bool isDark,
  }) {
    final textSpan = TextSpan(
      text: '$icon $name',
      style: TextStyle(
        color: isDark ? Colors.white70 : AppColors.primaryText,
        fontSize: (8.0 * zoomLevel).clamp(7.0, 11.0),
        fontWeight: FontWeight.w600,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = Rect.fromCenter(
      center: position,
      width: tp.width + 10,
      height: tp.height + 4,
    );

    final bgPaint = Paint()
      ..color = isDark
          ? Colors.black.withValues(alpha: 0.65)
          : Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      bgPaint,
    );

    tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy - tp.height / 2));
  }

  void _drawRoutePolylines({
    required Canvas canvas,
    required Size size,
    required List<Offset> completedPoints,
    required List<Offset> upcomingPoints,
  }) {
    // 1. Draw Upcoming Guide Trail (Ahead of runner)
    if (upcomingPoints.length > 1) {
      final upcomingPath = Path();
      upcomingPath.moveTo(upcomingPoints.first.dx, upcomingPoints.first.dy);
      for (int i = 1; i < upcomingPoints.length; i++) {
        upcomingPath.lineTo(upcomingPoints[i].dx, upcomingPoints[i].dy);
      }

      // Soft mint planned path glow
      final upcomingGlow = Paint()
        ..color = AppColors.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (8.0 * zoomLevel).clamp(5.0, 14.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(upcomingPath, upcomingGlow);

      // Core upcoming line
      final upcomingCore = Paint()
        ..color = isDark
            ? const Color(0xFF2C4844)
            : const Color(0xFF86E2D5).withValues(alpha: 0.70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (4.0 * zoomLevel).clamp(2.5, 7.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(upcomingPath, upcomingCore);
    }

    // 2. Draw Completed Trail (Where user has already run)
    if (completedPoints.length > 1) {
      final completedPath = Path();
      completedPath.moveTo(completedPoints.first.dx, completedPoints.first.dy);
      for (int i = 1; i < completedPoints.length; i++) {
        completedPath.lineTo(completedPoints[i].dx, completedPoints[i].dy);
      }

      // Vibrant Teal Outer Glow
      final completedGlow = Paint()
        ..color = AppColors.primaryTeal.withValues(alpha: isDark ? 0.55 : 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (12.0 * zoomLevel).clamp(8.0, 18.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawPath(completedPath, completedGlow);

      // High-Contrast Solid Black / Dark Charcoal Active Core
      final completedCore = Paint()
        ..color = isDark ? Colors.white : AppColors.statCapsuleDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = (5.5 * zoomLevel).clamp(3.5, 9.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(completedPath, completedCore);

      // Directional Chevrons along completed route
      if (completedPoints.length > 3) {
        final step = math.max(1, (completedPoints.length / 5).floor());
        for (int i = step; i < completedPoints.length - 1; i += step) {
          final p1 = completedPoints[i - 1];
          final p2 = completedPoints[i];
          final angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
          final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
          _drawDirectionArrow(canvas, mid, angle);
        }
      }
    }
  }

  void _drawDirectionArrow(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final arrowPaint = Paint()
      ..color = isDark ? const Color(0xFF0F2622) : const Color(0xFF86E2D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final arrowPath = Path()
      ..moveTo(-3, -3)
      ..lineTo(2, 0)
      ..lineTo(-3, 3);

    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();
  }

  void _drawKmSplitBadges(Canvas canvas, Size size) {
    final splitInterval = math.max(1, (routePoints.length / 3).floor());
    int km = 1;

    for (int i = splitInterval; i < routePoints.length - 1; i += splitInterval) {
      if (km > 3) break;
      final pos = _toPixel(routePoints[i], size);

      // Split Pin Pill
      final textSpan = TextSpan(
        text: '${km}K',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final pillRect = Rect.fromCenter(
        center: Offset(pos.dx, pos.dy - 12),
        width: tp.width + 10,
        height: 14,
      );

      final bgPaint = Paint()
        ..color = isDark ? AppColors.darkNavigation : const Color(0xFF1E2828)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(7)),
        bgPaint,
      );

      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - 12 - tp.height / 2),
      );

      // Tiny pin stalk
      canvas.drawCircle(pos, 2.5, bgPaint);
      km++;
    }
  }

  void _drawStartMarker(Canvas canvas, Offset pos) {
    // Outer white halo
    canvas.drawCircle(
      pos,
      9.0,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    // Inner bright green/teal start dot
    canvas.drawCircle(
      pos,
      6.0,
      Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.fill,
    );

    // Start Badge Flag Pill
    final textSpan = const TextSpan(
      text: 'START',
      style: TextStyle(
        color: Colors.white,
        fontSize: 7.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy - 14),
      width: tp.width + 8,
      height: 13,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(6)),
      Paint()..color = AppColors.success,
    );

    tp.paint(
      canvas,
      Offset(pos.dx - tp.width / 2, pos.dy - 14 - tp.height / 2),
    );
  }

  void _drawFinishMarker(Canvas canvas, Offset pos) {
    // Outer halo
    canvas.drawCircle(
      pos,
      8.0,
      Paint()..color = Colors.white,
    );

    // Inner dark circle
    canvas.drawCircle(
      pos,
      5.5,
      Paint()..color = isDark ? AppColors.darkMint : AppColors.primaryTeal,
    );

    // Finish Badge Pill
    final textSpan = const TextSpan(
      text: 'FINISH',
      style: TextStyle(
        color: Colors.white,
        fontSize: 7.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy - 14),
      width: tp.width + 8,
      height: 13,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(6)),
      Paint()..color = isDark ? const Color(0xFF1E2828) : AppColors.darkNavigation,
    );

    tp.paint(
      canvas,
      Offset(pos.dx - tp.width / 2, pos.dy - 14 - tp.height / 2),
    );
  }

  void _drawRunnerMarker({
    required Canvas canvas,
    required Offset pos,
    required double headingAngle,
  }) {
    // 1. Dual-tier animated sonar radar waves
    final r1 = 12.0 + (pulseValue * 26.0);
    final a1 = (1.0 - pulseValue) * 0.45;
    canvas.drawCircle(
      pos,
      r1,
      Paint()
        ..color = AppColors.primaryTeal.withValues(alpha: a1)
        ..style = PaintingStyle.fill,
    );

    final r2 = 7.0 + (pulseValue * 14.0);
    final a2 = (1.0 - pulseValue) * 0.60;
    canvas.drawCircle(
      pos,
      r2,
      Paint()
        ..color = const Color(0xFF86E2D5).withValues(alpha: a2)
        ..style = PaintingStyle.fill,
    );

    // 2. Drop Shadow under runner beacon
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // 3. Crisp white outer bezel ring
    canvas.drawCircle(
      pos,
      11.5,
      Paint()..color = Colors.white,
    );

    // 4. Center Dark Casing
    canvas.drawCircle(
      pos,
      8.5,
      Paint()..color = AppColors.statCapsuleDark,
    );

    // 5. Glowing Mint Inner Dot
    canvas.drawCircle(
      pos,
      4.5,
      Paint()..color = const Color(0xFF86E2D5),
    );

    // 6. Directional Forward Chevron pointing along headingAngle
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(headingAngle + (math.pi / 2)); // Align upright arrow with heading

    final headingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final headingPath = Path()
      ..moveTo(0, -6)
      ..lineTo(3.5, 3)
      ..lineTo(0, 1.5)
      ..lineTo(-3.5, 3)
      ..close();

    canvas.drawPath(headingPath, headingPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FakeVectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.runProgress != runProgress ||
        oldDelegate.runnerPoint != runnerPoint ||
        oldDelegate.routePoints != routePoints ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isLive != isLive;
  }
}
