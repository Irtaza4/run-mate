import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Featured Mint Challenge card with animated progress indicator
class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback? onJoinTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onJoinTap,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnim = Tween<double>(
      begin: 0.0,
      end: widget.challenge.progressRatio,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.currentKm != widget.challenge.currentKm) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.challenge.progressRatio,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ));
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1B2A27) : AppColors.mint;
    final primaryTextColor = isDark ? Colors.white : AppColors.primaryText;
    final mutedTextColor =
        isDark ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF2A423E);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(
                color: AppColors.darkMint.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMint : AppColors.mint)
                .withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Days Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkMint.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.military_tech_rounded,
                      size: 18,
                      color: isDark ? AppColors.darkMint : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.challenge.title,
                    style: AppTypography.headingSmall(color: primaryTextColor)
                        .copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.challenge.daysLeft > 0
                      ? '${widget.challenge.daysLeft} days left'
                      : 'Completed',
                  style: AppTypography.caption(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Challenge description & target
          Text(
            widget.challenge.description,
            style: AppTypography.bodyMedium(
              color: mutedTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Numeric Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.challenge.currentKm.toStringAsFixed(0),
                    style: AppTypography.displayMedium(color: primaryTextColor)
                        .copyWith(fontSize: 28),
                  ),
                  Text(
                    ' / ${widget.challenge.targetKm.toStringAsFixed(0)} km',
                    style: AppTypography.headingSmall(color: mutedTextColor)
                        .copyWith(fontSize: 18),
                  ),
                ],
              ),
              Text(
                '${(widget.challenge.progressRatio * 100).toInt()}%',
                style: AppTypography.headingSmall(color: primaryTextColor)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Animated Rounded Progress Bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return Stack(
                children: [
                  // Track background
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  // Progress fill
                  FractionallySizedBox(
                    widthFactor: _progressAnim.value.clamp(0.02, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkMint
                            : AppColors.primaryText,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Supporting details footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.challenge.remainingKm > 0
                    ? '${widget.challenge.remainingKm.toStringAsFixed(1)} km remaining'
                    : 'Goal reached! 🎉',
                style: AppTypography.caption(
                  color: mutedTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!widget.challenge.isJoined)
                GestureDetector(
                  onTap: widget.onJoinTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryText,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Join Challenge',
                      style: AppTypography.caption(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
