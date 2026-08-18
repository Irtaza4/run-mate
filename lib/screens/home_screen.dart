import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/cards/challenge_card.dart';
import '../widgets/charts/activity_bar_chart.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/common/metric_card.dart';
import 'run_detail_screen.dart';

/// Main Home Dashboard screen
class HomeScreen extends StatelessWidget {
  final AppState state;
  final VoidCallback onStartRunTap;
  final VoidCallback onExploreTap;
  final VoidCallback onProfileTap;

  const HomeScreen({
    super.key,
    required this.state,
    required this.onStartRunTap,
    required this.onExploreTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: _buildHeader(context, isDark),
              ),
            ),

            // Start Run Quick Action Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _buildStartRunBanner(context, isDark),
              ),
            ),

            // Today's Statistics Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatisticsGrid(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Weekly Activity Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ActivityBarChart(
                  activities: state.weekActivities,
                  activeFilter: state.chartFilter,
                  onFilterChanged: state.setChartFilter,
                  onDaySelected: state.selectDay,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Active Monthly Challenge Showcase
            if (state.challenges.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ChallengeCard(
                    challenge: state.challenges.first,
                    onJoinTap: () => state.toggleJoinChallenge(state.challenges.first.id),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Recent Activity Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildRecentActivitySection(context, isDark),
              ),
            ),

            // Bottom Spacing for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hello, ${state.userName}',
                  style: AppTypography.headingLarge(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('👋', style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Good morning • Ready for a run?',
              style: AppTypography.caption(
                color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButtonCapsule(
              icon: Icons.notifications_none_rounded,
              onPressed: () {
                _showNotificationSheet(context, isDark);
              },
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkMint : AppColors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'JS',
                  style: AppTypography.caption(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartRunBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2423) : AppColors.darkNavigation,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to hit the road?',
                style: AppTypography.headingSmall(color: Colors.white)
                    .copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                'GPS Signal Ready • Optimal Weather',
                style: AppTypography.caption(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onStartRunTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkMint : AppColors.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: AppColors.primaryText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Start',
                    style: AppTypography.buttonText(
                      color: AppColors.primaryText,
                    ).copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Statistics",
                style: AppTypography.headingSmall(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              Text(
                'Live Sync',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Distance',
                value: '7.2',
                unit: 'km',
                icon: Icons.straighten_rounded,
                iconColor: const Color(0xFF0F9B82),
                iconBgColor: AppColors.mint.withValues(alpha: 0.35),
                subtitle: '+12% vs avg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Heart Rate',
                value: '128',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                iconColor: AppColors.danger,
                iconBgColor: AppColors.danger.withValues(alpha: 0.16),
                subtitle: 'Zone 2',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Calories',
                value: '520',
                unit: 'kcal',
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFE89020),
                iconBgColor: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Avg Pace',
                value: '5:32',
                unit: '/km',
                icon: Icons.speed_rounded,
                iconColor: AppColors.primaryTeal,
                iconBgColor: AppColors.primaryTeal.withValues(alpha: 0.16),
                subtitle: 'Steady',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, bool isDark) {
    if (state.runHistory.isEmpty) return const SizedBox.shrink();
    final latestRun = state.runHistory.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.headingSmall(
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
            ),
            GestureDetector(
              onTap: () {
                state.setTabIndex(3); // Navigate to Activity tab
              },
              child: Text(
                'See All',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialNavigationRoute(
                builder: (ctx) => RunDetailScreen(run: latestRun),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: isDark
                  ? Border.all(color: AppColors.darkDivider)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondarySurface
                        : AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_run_rounded,
                    color: AppColors.primaryTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestRun.title,
                        style: AppTypography.bodyLarge(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${latestRun.formattedDistance} km • ${latestRun.formattedDuration} • ${latestRun.formattedPace} /km',
                        style: AppTypography.caption(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Notifications',
                style: AppTypography.headingMedium(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              _buildNotificationItem(
                title: 'Weekly Goal on Track! 🎯',
                body: 'You completed 18.2 km out of your 25 km goal.',
                time: '2h ago',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                title: 'Elena cheered your run! ✋',
                body: 'Elena Rostova gave a high five on One River Park.',
                time: '5h ago',
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Dismiss',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String body,
    required String time,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondarySurface : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium(
                  color: isDark ? Colors.white : AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTypography.caption(
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialNavigationRoute<T> extends MaterialPageRoute<T> {
  MaterialNavigationRoute({required super.builder});
}
