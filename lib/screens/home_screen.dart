import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/cards/challenge_card.dart';
import '../widgets/cards/stacked_stat_cards_carousel.dart';
import '../widgets/charts/stacked_tile_activity_chart.dart';
import '../widgets/common/custom_buttons.dart';
import 'run_detail_screen.dart';

/// Main Home Dashboard Screen matching the exact reference design
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header: "Hello, Julia Let's train!" + 3-dots + Avatar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: _buildHeader(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 2. Section Header: "Check your stats" + Timeframe filter (Day, W, M, Y)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsHeader(isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 3. Stats Horizontal Carousel (Steps, Heart Rate, Calories...)
            SliverToBoxAdapter(
              child: _buildStatsCarousel(context, isDark),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 4. "Your Activity" Large White Section with Stacked Tile Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildYourActivityCard(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 5. Start Run Quick Action Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStartRunBanner(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 6. Active Challenge Showcase (if any)
            if (state.challenges.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ChallengeCard(
                    challenge: state.challenges.first,
                    onJoinTap: () =>
                        state.toggleJoinChallenge(state.challenges.first.id),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 7. Recent Activity History item
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildRecentActivitySection(context, isDark),
              ),
            ),

            // Bottom Spacing for floating navigation capsule
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: "Hello, Julia  Let's train!"
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  'Hello, ${state.userName}',
                  style: AppTypography.headingLarge(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ).copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Let's train!",
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMutedText : AppColors.subtleGray,
                  fontWeight: FontWeight.w400,
                ).copyWith(fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right: 3-dots options button + Julia Avatar with lavender dot
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3-dots Button
            GestureDetector(
              onTap: () => _showQuickActionsSheet(context, isDark),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDivider
                        : Colors.black.withValues(alpha: 0.04),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: isDark ? Colors.white : AppColors.primaryText,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Profile Avatar with lavender notification dot
            GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/julia_avatar.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryTeal,
                            alignment: Alignment.center,
                            child: const Text(
                              'JS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Lavender Notification Dot indicator at top-left edge
                  Positioned(
                    top: 1,
                    left: 2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.lavenderBadge,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lavenderBadge.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- "Check your stats" Header + Timeframe Tabs ---
  Widget _buildStatsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Check your stats',
          style: AppTypography.headingLarge(
            color: isDark ? Colors.white : AppColors.primaryText,
          ).copyWith(
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),

        // Timeframe selector (Day, W, M, Y)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: state.statTimeframeOptions.map((option) {
            final isSelected = state.statTimeframe == option;
            return GestureDetector(
              onTap: () => state.setStatTimeframe(option),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : AppColors.primaryText)
                        : (isDark ? AppColors.darkMutedText : AppColors.subtleGray),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 3D Stacked Deck Stats Carousel ---
  Widget _buildStatsCarousel(BuildContext context, bool isDark) {
    final metrics = state.statMetrics;

    return StackedStatCardsCarousel(
      metrics: metrics,
      onCardTap: (m) => _showMetricDetailSheet(context, m, isDark),
    );
  }

  // --- "Your Activity" Card with Stacked Tile Chart ---
  Widget _buildYourActivityCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(38),
        border: isDark
            ? Border.all(color: AppColors.darkDivider)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Your Activity   For today" + "More >" capsule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Your Activity',
                    style: AppTypography.headingMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ).copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'For today',
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.subtleGray,
                    ).copyWith(fontSize: 13),
                  ),
                ],
              ),

              // "More >" button
              GestureDetector(
                onTap: () => state.setTabIndex(0), // Navigate to Activity History (Tab 0)
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondarySurface
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.divider,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'More',
                        style: AppTypography.caption(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.subtleGray,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stacked Tile Chart
          StackedTileActivityChart(
            blocks: state.hourlyBlocks,
            selectedIndex: state.selectedHourlyIndex,
            onSelectBlock: (idx) => state.selectHourlyBlock(idx),
          ),
        ],
      ),
    );
  }

  // --- Start Run Banner ---
  Widget _buildStartRunBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2423) : AppColors.darkNavigation,
        borderRadius: BorderRadius.circular(28),
        border: isDark
            ? Border.all(color: const Color(0xFF2C3E3A), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
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
                  color: isDark ? AppColors.darkMutedText : Colors.white.withValues(alpha: 0.65),
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

  // --- Recent Activity Section ---
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
                state.setTabIndex(0); // Navigate to Activity tab (Tab 0)
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
              borderRadius: BorderRadius.circular(26),
              border: isDark
                  ? Border.all(color: AppColors.darkDivider)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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

  // --- Quick Actions / Notifications Sheet ---
  void _showQuickActionsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Training Options',
                    style: AppTypography.headingMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primaryTeal),
                ),
                title: Text(
                  'Daily Goals & Targets',
                  style: AppTypography.bodyMedium(
                    color: isDark ? Colors.white : AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Adjust step targets and heart rate zones',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  onProfileTap();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBadge.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: Color(0xFF8B5CF6)),
                ),
                title: Text(
                  'Activity Notifications',
                  style: AppTypography.bodyMedium(
                    color: isDark ? Colors.white : AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '2 new cheers and milestone alerts',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Done',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMetricDetailSheet(
      BuildContext context, StatMetric metric, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                '${metric.title} Breakdown',
                style: AppTypography.headingMedium(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Current: ${metric.value} ${metric.targetOrUnit} (${metric.trendText})',
                style: AppTypography.bodyLarge(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: metric.progress,
                backgroundColor: isDark ? AppColors.darkSecondarySurface : AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryTeal),
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Close',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MaterialNavigationRoute<T> extends MaterialPageRoute<T> {
  MaterialNavigationRoute({required super.builder});
}
