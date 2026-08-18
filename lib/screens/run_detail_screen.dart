import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/charts/splits_list_view.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/maps/route_map_view.dart';

/// Detailed analytical breakdown of a single completed run
class RunDetailScreen extends StatelessWidget {
  final RunActivity run;

  const RunDetailScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('EEEE, MMM d, y • h:mm a').format(run.date);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        leading: IconButtonCapsule(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.pop(context),
          size: 40,
        ),
        title: Text(
          'Run Analytics',
          style: AppTypography.headingSmall(
            color: isDark ? Colors.white : AppColors.primaryText,
          ),
        ),
        actions: [
          IconButtonCapsule(
            icon: Icons.share_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity link copied!')),
              );
            },
            size: 40,
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Date Header
            Text(
              run.title,
              style: AppTypography.headingLarge(
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: AppTypography.caption(
                color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),

            // Route Map with interactive controls
            RouteMapView(
              routeCoordinates: run.routeCoordinates,
              height: 220,
              showControls: true,
            ),
            const SizedBox(height: 20),

            // Overview 4-Metric Grid
            _buildOverviewCards(context, isDark),
            const SizedBox(height: 16),

            // Secondary Stats Bar (Elevation, Cadence, Max HR)
            _buildSecondaryStatsRow(context, isDark),
            const SizedBox(height: 20),

            // Heart Rate Zone distribution card
            _buildHeartRateZonesCard(context, isDark),
            const SizedBox(height: 20),

            // Splits breakdown
            SplitsListView(splits: run.splits),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailMetric(
                  label: 'DISTANCE',
                  value: '${run.formattedDistance} km',
                  isDominant: true,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildDetailMetric(
                  label: 'DURATION',
                  value: run.formattedDuration,
                  isDominant: true,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildDetailMetric(
                  label: 'AVG PACE',
                  value: '${run.formattedPace}/km',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildDetailMetric(
                  label: 'CALORIES',
                  value: '${run.calories} kcal',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMetric({
    required String label,
    required String value,
    bool isDominant = false,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.metricLabel(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (isDominant
                  ? AppTypography.headingLarge(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    )
                  : AppTypography.headingSmall(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ))
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSecondaryStatsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            icon: Icons.terrain_rounded,
            label: 'Elevation',
            value: '+${run.elevationGainM} m',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniStat(
            icon: Icons.repeat_rounded,
            label: 'Cadence',
            value: '${run.cadence} spm',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMiniStat(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.danger,
            label: 'Max HR',
            value: '${run.maxHeartRate} bpm',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? (isDark ? AppColors.darkMint : AppColors.primaryTeal),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: AppTypography.metricLabel(
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ).copyWith(fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.caption(
              color: isDark ? Colors.white : AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateZonesCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Heart Rate Intensity Zones',
                style: AppTypography.headingSmall(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              Text(
                'Avg ${run.avgHeartRate} bpm',
                style: AppTypography.caption(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildZoneBar(name: 'Zone 5 (Max >165 bpm)', percent: 0.12, color: AppColors.danger, isDark: isDark),
          const SizedBox(height: 8),
          _buildZoneBar(name: 'Zone 4 (Threshold 150-165)', percent: 0.38, color: AppColors.warning, isDark: isDark),
          const SizedBox(height: 8),
          _buildZoneBar(name: 'Zone 3 (Aerobic 135-150)', percent: 0.35, color: isDark ? AppColors.darkMint : AppColors.primaryTeal, isDark: isDark),
          const SizedBox(height: 8),
          _buildZoneBar(name: 'Zone 2 (Easy <135 bpm)', percent: 0.15, color: AppColors.success, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildZoneBar({
    required String name,
    required double percent,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTypography.caption(
                color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: AppTypography.caption(
                color: isDark ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: isDark ? AppColors.darkSecondarySurface : AppColors.secondarySurface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
