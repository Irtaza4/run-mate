import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/custom_buttons.dart';

/// Social Team section with avatar avatars and detail modal
class TeamAvatarList extends StatelessWidget {
  final List<TeamMember> members;
  final VoidCallback? onAddTeammate;

  const TeamAvatarList({
    super.key,
    required this.members,
    this.onAddTeammate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBackground;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(color: AppColors.darkDivider, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Team',
                style: AppTypography.headingSmall(
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSecondarySurface
                      : AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${members.length} Runners',
                  style: AppTypography.caption(
                    color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Avatars Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                ...members.map((member) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildTeammateAvatar(context, member, isDark),
                    )),
                // Add Teammate Button [+]
                _buildAddButton(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeammateAvatar(
      BuildContext context, TeamMember member, bool isDark) {
    return GestureDetector(
      onTap: () => _showMemberDetailModal(context, member),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: member.avatarBgColor.withValues(alpha: isDark ? 0.25 : 0.20),
              shape: BoxShape.circle,
              border: Border.all(
                color: member.avatarBgColor,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              member.avatarInitials,
              style: AppTypography.caption(
                color: isDark ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.w700,
              ).copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 58,
            child: Text(
              member.name.split(' ').first,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption(
                color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ).copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (onAddTeammate != null) {
          onAddTeammate!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invite link copied to clipboard!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondarySurface
                  : AppColors.secondarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.divider,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.add_rounded,
              size: 24,
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Invite',
            style: AppTypography.caption(
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showMemberDetailModal(BuildContext context, TeamMember member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar & Name
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: member.avatarBgColor.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: member.avatarBgColor, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  member.avatarInitials,
                  style: AppTypography.headingMedium(
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                member.name,
                style: AppTypography.headingMedium(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${member.role} • Active ${member.lastActive}',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildModalStat(
                      label: 'Weekly',
                      value: '${member.weeklyKm.toStringAsFixed(1)} km',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModalStat(
                      label: 'Streak',
                      value: '${member.streakDays} days',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModalStat(
                      label: 'Runs',
                      value: '${member.totalRuns}',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Send High Five Button
              PrimaryButton(
                text: 'Send High Five ✋',
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You cheered on ${member.name.split(' ').first}! 🏃💨'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalStat({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondarySurface : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: AppTypography.metricLabel(
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headingSmall(
              color: isDark ? Colors.white : AppColors.primaryText,
            ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
