import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// A sleek pill capsule stat card matching the reference design
class StatCapsuleCard extends StatelessWidget {
  final StatMetric metric;
  final VoidCallback? onTap;

  const StatCapsuleCard({
    super.key,
    required this.metric,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 172,
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2222) : AppColors.statCapsuleDark,
          borderRadius: BorderRadius.circular(38),
          border: isDark
              ? Border.all(color: const Color(0xFF2E3836), width: 1.3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
        child: Column(
          children: [
            // Top Header: Icon + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                children: [
                  _buildIcon(metric.iconType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metric.title,
                      style: AppTypography.bodyMedium(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Inner Bubble Container with Value, Trend & Bottom Arc
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131717) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isDark
                      ? Border.all(color: const Color(0xFF222A29), width: 1.0)
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Text details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Value + Denominator
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  metric.value,
                                  style: AppTypography.headingLarge(
                                    color: isDark ? Colors.white : AppColors.primaryText,
                                  ).copyWith(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  metric.targetOrUnit,
                                  style: AppTypography.caption(
                                    color: isDark ? AppColors.darkMutedText : AppColors.subtleGray,
                                    fontWeight: FontWeight.w600,
                                  ).copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 3),

                          // Trend indicator (e.g. 15% more ↗ / 32% lower ↘)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  metric.trendText,
                                  style: AppTypography.caption(
                                    color: isDark ? const Color(0xFF9EDFD5) : AppColors.primaryText,
                                    fontWeight: FontWeight.w500,
                                  ).copyWith(fontSize: 12),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  metric.isTrendUp
                                      ? Icons.north_east_rounded
                                      : Icons.south_east_rounded,
                                  size: 13,
                                  color: isDark ? const Color(0xFF9EDFD5) : AppColors.primaryText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Curved Progress Gauge hugging the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      top: 40,
                      child: CustomPaint(
                        painter: BottomCurvedProgressPainter(
                          progress: metric.progress,
                          trackColor: isDark ? const Color(0xFF222B2A) : AppColors.statArcTrack,
                          activeStartColor: isDark ? const Color(0xFFB8F3EA) : AppColors.statArcMintLight,
                          activeEndColor: isDark ? const Color(0xFF4AC4B3) : AppColors.statArcMintDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(StatIconType type) {
    switch (type) {
      case StatIconType.steps:
        return const _FootprintsIcon();
      case StatIconType.heartRate:
        return const Icon(
          Icons.favorite_border_rounded,
          color: Colors.white,
          size: 18,
        );
      case StatIconType.calories:
        return const Icon(
          Icons.local_fire_department_outlined,
          color: Colors.white,
          size: 19,
        );
      case StatIconType.distance:
        return const Icon(
          Icons.straighten_rounded,
          color: Colors.white,
          size: 18,
        );
      case StatIconType.pace:
        return const Icon(
          Icons.speed_rounded,
          color: Colors.white,
          size: 18,
        );
    }
  }
}

/// Custom painted two-footprint outline icon matching the reference
class _FootprintsIcon extends StatelessWidget {
  const _FootprintsIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _FootprintsPainter(),
    );
  }
}

class _FootprintsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left Footprint
    canvas.save();
    canvas.translate(size.width * 0.22, size.height * 0.38);
    canvas.rotate(-0.15);
    // Foot sole
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 3), width: 5.5, height: 9),
        const Radius.circular(2.8),
      ),
      paint,
    );
    // Toes dot
    canvas.drawCircle(const Offset(0, -3.2), 1.2, dotPaint);
    canvas.restore();

    // Right Footprint (slightly higher)
    canvas.save();
    canvas.translate(size.width * 0.72, size.height * 0.24);
    canvas.rotate(0.12);
    // Foot sole
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 3), width: 5.5, height: 9),
        const Radius.circular(2.8),
      ),
      paint,
    );
    // Toes dot
    canvas.drawCircle(const Offset(0, -3.2), 1.2, dotPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the curved bottom progress gauge
class BottomCurvedProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color activeStartColor;
  final Color activeEndColor;

  BottomCurvedProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.activeStartColor,
    required this.activeEndColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final w = size.width;
    final h = size.height;
    const radius = 26.0;
    const strokeW = 4.5;
    const inset = 6.0;

    final left = inset;
    final right = w - inset;
    final bottom = h - inset;
    final startY = (h - radius * 1.5).clamp(0.0, bottom);

    final trackPath = Path();
    trackPath.moveTo(left, startY);
    trackPath.arcToPoint(
      Offset(left + radius, bottom),
      radius: const Radius.circular(radius),
      clockwise: false,
    );
    trackPath.lineTo(right - radius, bottom);
    trackPath.arcToPoint(
      Offset(right, startY),
      radius: const Radius.circular(radius),
      clockwise: false,
    );

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(trackPath, trackPaint);

    final metricsList = trackPath.computeMetrics().toList();
    if (metricsList.isEmpty) return;
    final pathMetric = metricsList.first;
    if (pathMetric.length <= 0) return;

    final activeLen = (pathMetric.length * progress.clamp(0.05, 1.0));
    final activePath = pathMetric.extractPath(0.0, activeLen);

    final gradient = LinearGradient(
      colors: [activeStartColor, activeEndColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final activePaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(activePath, activePaint);

    final startTangent = pathMetric.getTangentForOffset(0);
    if (startTangent != null) {
      final dotPaint = Paint()
        ..color = activeStartColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(startTangent.position, strokeW * 0.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BottomCurvedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.activeStartColor != activeStartColor ||
        oldDelegate.activeEndColor != activeEndColor;
  }
}
