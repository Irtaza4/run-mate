import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/charts/splits_list_view.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/maps/route_map_view.dart';

/// Run Completion Celebration and Summary screen
class RunSummaryScreen extends StatelessWidget {
  final RunActivity run;

  const RunSummaryScreen({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Celebration Badge & Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkMint.withValues(alpha: 0.25)
                            : AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🎉', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Great Run!',
                      style: AppTypography.headingLarge(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ).copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${run.title} • Activity saved successfully',
                      style: AppTypography.caption(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Route Map Snapshot
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: RouteMapView(
                  routeCoordinates: run.routeCoordinates,
                  height: 200,
                  showControls: false,
                ),
              ),
              const SizedBox(height: 20),

              // Large Primary Metrics Grid
              _buildMetricsSummaryCard(context, isDark),
              const SizedBox(height: 20),

              // Kilometer Splits Breakdown
              SplitsListView(splits: run.splits),
              const SizedBox(height: 24),

              // Action Buttons
              PrimaryButton(
                text: 'Done',
                height: 56,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Share Run',
                icon: Icons.share_rounded,
                height: 50,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Run summary card generated and copied! 🏃✨'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSummaryCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkDivider)
            : null,
      ),
      child: Column(
        children: [
          // Dominant Distance
          Column(
            children: [
              Text(
                'TOTAL DISTANCE',
                style: AppTypography.metricLabel(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    run.formattedDistance,
                    style: AppTypography.displayLarge(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ).copyWith(fontSize: 44, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'km',
                    style: AppTypography.headingMedium(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // 2x2 Grid of Secondary Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'DURATION',
                  value: run.formattedDuration,
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  label: 'AVG PACE',
                  value: '${run.formattedPace}/km',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  label: 'CALORIES',
                  value: '${run.calories} kcal',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  label: 'AVG HEART RATE',
                  value: '${run.avgHeartRate} bpm',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
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
          style: AppTypography.headingSmall(
            color: isDark ? Colors.white : AppColors.primaryText,
          ).copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
