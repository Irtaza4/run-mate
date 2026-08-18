import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/maps/route_map_view.dart';
import 'run_detail_screen.dart';

/// Activity history log screen with historical runs and aggregated totals
class ActivityHistoryScreen extends StatefulWidget {
  final AppState state;

  const ActivityHistoryScreen({super.key, required this.state});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _selectedTimeframe = 'All Time';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final runs = widget.state.runHistory;

    // Filter runs by timeframe
    final filteredRuns = _getFilteredRuns(runs);

    final totalKm = filteredRuns.fold<double>(0.0, (sum, r) => sum + r.distanceKm);
    final totalCalories = filteredRuns.fold<int>(0, (sum, r) => sum + r.calories);
    final avgPace = filteredRuns.isNotEmpty
        ? filteredRuns.fold<double>(0.0, (sum, r) => sum + r.avgPaceMinPerKm) /
            filteredRuns.length
        : 5.5;

    final avgPaceMinutes = avgPace.floor();
    final avgPaceSeconds = ((avgPace - avgPaceMinutes) * 60).round();
    final formattedAvgPace =
        '$avgPaceMinutes:${avgPaceSeconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity History',
                          style: AppTypography.headingLarge(
                            color: isDark ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Log of your training sessions and achievements',
                          style: AppTypography.caption(
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Timeframe Selector Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: _buildTimeframeFilter(isDark),
              ),
            ),

            // Aggregated Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAggregatedStatsBanner(
                  totalKm: totalKm,
                  runCount: filteredRuns.length,
                  avgPace: formattedAvgPace,
                  totalCalories: totalCalories,
                  isDark: isDark,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Section Label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Completed Runs',
                  style: AppTypography.headingSmall(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Runs List or Empty State
            if (filteredRuns.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.directions_run_rounded,
                            size: 48, color: AppColors.mutedText),
                        const SizedBox(height: 12),
                        Text(
                          'No runs found for this period',
                          style: AppTypography.bodyMedium(
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final run = filteredRuns[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildRunHistoryItem(context, run, isDark),
                      );
                    },
                    childCount: filteredRuns.length,
                  ),
                ),
              ),

            // Bottom Spacing for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<RunActivity> _getFilteredRuns(List<RunActivity> runs) {
    final now = DateTime.now();
    if (_selectedTimeframe == 'This Week') {
      return runs
          .where((r) => now.difference(r.date).inDays <= 7)
          .toList();
    } else if (_selectedTimeframe == 'This Month') {
      return runs
          .where((r) => now.difference(r.date).inDays <= 30)
          .toList();
    }
    return runs;
  }

  Widget _buildTimeframeFilter(bool isDark) {
    const timeframes = ['All Time', 'This Month', 'This Week'];

    return Row(
      children: timeframes.map((tf) {
        final isSelected = _selectedTimeframe == tf;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeframe = tf;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkMint : AppColors.primaryText)
                    : (isDark ? AppColors.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: isDark
                    ? Border.all(
                        color: isSelected
                            ? AppColors.darkMint
                            : AppColors.darkDivider)
                    : null,
              ),
              child: Text(
                tf,
                style: AppTypography.caption(
                  color: isSelected
                      ? (isDark ? AppColors.darkBackground : Colors.white)
                      : (isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ).copyWith(fontSize: 12),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAggregatedStatsBanner({
    required double totalKm,
    required int runCount,
    required String avgPace,
    required int totalCalories,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryColumn('DISTANCE', '${totalKm.toStringAsFixed(1)} km', isDark),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          _buildSummaryColumn('TOTAL RUNS', '$runCount', isDark),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          _buildSummaryColumn('AVG PACE', '$avgPace/km', isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.metricLabel(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headingSmall(
            color: isDark ? Colors.white : AppColors.primaryText,
          ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildRunHistoryItem(
      BuildContext context, RunActivity run, bool isDark) {
    final dateStr = _formatRelativeDate(run.date);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => RunDetailScreen(run: run),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: isDark ? Border.all(color: AppColors.darkDivider) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Route Mini Map Canvas thumbnail
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: RouteMapView(
                routeCoordinates: run.routeCoordinates,
                height: 68,
                showControls: false,
              ),
            ),
            const SizedBox(width: 14),

            // Run Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: AppTypography.caption(
                          color: isDark
                              ? AppColors.darkMint
                              : AppColors.primaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (run.isPersonalRecord)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PR ⚡',
                            style: AppTypography.caption(
                              color: const Color(0xFFC78F0A),
                              fontWeight: FontWeight.w700,
                            ).copyWith(fontSize: 9),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    run.title,
                    style: AppTypography.bodyMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${run.formattedDistance} km  •  ${run.formattedDuration}  •  ${run.formattedPace} /km',
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 12 && now.day == date.day) {
      return 'Today';
    } else if (difference.inDays == 1 ||
        (now.day - date.day == 1 && difference.inHours < 36)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    }
    return DateFormat('MMM d, y').format(date);
  }
}
