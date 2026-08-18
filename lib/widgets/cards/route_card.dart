import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../maps/route_map_view.dart';

/// Suggested Route preview card with quiet vector thumbnail and stats
class RouteCard extends StatelessWidget {
  final SuggestedRoute route;
  final VoidCallback? onSelectRoute;
  final VoidCallback? onStartRun;

  const RouteCard({
    super.key,
    required this.route,
    this.onSelectRoute,
    this.onStartRun,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBackground;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkDivider, width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map preview thumbnail with difficulty badge
          Stack(
            children: [
              RouteMapView(
                routeCoordinates: route.pathCoordinates,
                height: 140,
                showControls: false,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(route.difficulty),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        route.difficulty,
                        style: AppTypography.caption(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.terrain_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.mutedText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${route.elevationGainM}m',
                        style: AppTypography.caption(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Route Details & Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  style: AppTypography.headingSmall(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  route.location,
                  style: AppTypography.caption(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 12),

                // Metrics row + Action CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildMetricChip(
                          icon: Icons.straighten_rounded,
                          text: '${route.distanceKm} km',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: Icons.timer_outlined,
                          text: '~${route.estDurationMinutes} min',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onStartRun ?? onSelectRoute,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkMint : AppColors.primaryText,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Select',
                              style: AppTypography.caption(
                                color: isDark ? AppColors.darkBackground : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: isDark ? AppColors.darkBackground : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondarySurface : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.caption(
              color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'moderate':
        return AppColors.warning;
      case 'challenging':
      case 'hard':
        return AppColors.danger;
      default:
        return AppColors.primaryTeal;
    }
  }
}
