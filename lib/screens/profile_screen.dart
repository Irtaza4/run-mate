import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/custom_buttons.dart';

/// Profile & Settings screen
class ProfileScreen extends StatefulWidget {
  final AppState state;

  const ProfileScreen({super.key, required this.state});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _useMetricUnits = true;
  bool _voiceFeedback = true;
  bool _autoPause = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: AppTypography.headingLarge(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    IconButtonCapsule(
                      icon: isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      onPressed: () {
                        widget.state.toggleDarkMode();
                      },
                      tooltip: 'Toggle Theme',
                    ),
                  ],
                ),
              ),
            ),

            // Profile Header Card (Avatar + Name + Bio)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildProfileHeaderCard(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // All-Time Summary Stats Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildAllTimeStatsCard(context, isDark),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Goals Progress Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goals & Targets',
                      style: AppTypography.headingSmall(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildGoalProgressCard(
                      title: 'Weekly Target',
                      current: 18.2,
                      target: state.weeklyGoalKm,
                      unit: 'km',
                      daysLeft: '3 days left',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildGoalProgressCard(
                      title: 'Monthly Mileage',
                      current: 74.5,
                      target: state.monthlyGoalKm,
                      unit: 'km',
                      daysLeft: '13 days left',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Achievements Badges Showcase
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Achievements',
                          style: AppTypography.headingSmall(
                            color: isDark ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                        Text(
                          '${state.achievements.where((a) => a.isUnlocked).length}/${state.achievements.length} Unlocked',
                          style: AppTypography.caption(
                            color: isDark
                                ? AppColors.darkMint
                                : AppColors.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementsGrid(context, isDark),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Settings & Preferences
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AppTypography.headingSmall(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsCard(context, isDark),
                  ],
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

  Widget _buildProfileHeaderCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkMint : AppColors.mint,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkDivider : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'JS',
              style: AppTypography.headingMedium(
                color: AppColors.primaryText,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.state.userFullTitle,
                  style: AppTypography.headingMedium(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.state.userBio,
                  style: AppTypography.caption(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondarySurface
                        : AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🔥 ${widget.state.currentStreakDays} Day Streak',
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.darkMint
                          : AppColors.primaryTeal,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Edit profile icon
          IconButtonCapsule(
            icon: Icons.edit_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile opened')),
              );
            },
            size: 38,
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeStatsCard(BuildContext context, bool isDark) {
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
          _buildProfileStatColumn(
            label: 'TOTAL DISTANCE',
            value: '${widget.state.totalDistanceKm.toStringAsFixed(0)} km',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          _buildProfileStatColumn(
            label: 'TOTAL RUNS',
            value: '${widget.state.totalRuns}',
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          _buildProfileStatColumn(
            label: 'BEST PACE',
            value: widget.state.bestPace,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatColumn({
    required String label,
    required String value,
    required bool isDark,
  }) {
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

  Widget _buildGoalProgressCard({
    required String title,
    required double current,
    required double target,
    required String unit,
    required String daysLeft,
    required bool isDark,
  }) {
    final ratio = (current / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge(
                  color: isDark ? Colors.white : AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ).copyWith(fontSize: 15),
              ),
              Text(
                daysLeft,
                style: AppTypography.caption(
                  color: isDark
                      ? AppColors.darkMutedText
                      : AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
                style: AppTypography.caption(
                  color: isDark ? Colors.white : AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(ratio * 100).toInt()}%',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.darkSecondarySurface
                  : AppColors.secondarySurface,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.darkMint : AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: widget.state.achievements.length,
      itemBuilder: (context, index) {
        final ach = widget.state.achievements[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDark ? Border.all(color: AppColors.darkDivider) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ach.isUnlocked
                          ? ach.iconColor.withValues(alpha: 0.2)
                          : (isDark
                              ? AppColors.darkSecondarySurface
                              : AppColors.secondarySurface),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      ach.icon,
                      size: 20,
                      color: ach.isUnlocked
                          ? ach.iconColor
                          : (isDark
                              ? AppColors.darkMutedText
                              : AppColors.mutedText),
                    ),
                  ),
                  if (ach.isUnlocked)
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.success),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ach.title,
                    style: AppTypography.bodyMedium(
                      color: isDark ? Colors.white : AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ).copyWith(fontSize: 13),
                  ),
                  Text(
                    ach.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
      ),
      child: Column(
        children: [
          // Dark Mode switch
          _buildSettingsSwitchTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Theme',
            value: widget.state.isDarkMode,
            onChanged: (val) => widget.state.toggleDarkMode(),
            isDark: isDark,
          ),
          const Divider(height: 1),

          // Unit system (km vs miles)
          _buildSettingsSwitchTile(
            icon: Icons.straighten_rounded,
            title: 'Metric Units (km)',
            value: _useMetricUnits,
            onChanged: (val) {
              setState(() {
                _useMetricUnits = val;
              });
            },
            isDark: isDark,
          ),
          const Divider(height: 1),

          // Voice feedback
          _buildSettingsSwitchTile(
            icon: Icons.record_voice_over_rounded,
            title: 'Audio Voice Feedback',
            value: _voiceFeedback,
            onChanged: (val) {
              setState(() {
                _voiceFeedback = val;
              });
            },
            isDark: isDark,
          ),
          const Divider(height: 1),

          // Auto-pause
          _buildSettingsSwitchTile(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Auto-Pause when Stopped',
            value: _autoPause,
            onChanged: (val) {
              setState(() {
                _autoPause = val;
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkMint : AppColors.primaryTeal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium(
                color: isDark ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: isDark ? AppColors.darkMint : AppColors.primaryTeal,
          ),
        ],
      ),
    );
  }
}
