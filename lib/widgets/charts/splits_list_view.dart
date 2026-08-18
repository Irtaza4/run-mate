import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Clean, high-contrast breakdown of Kilometer Splits
class SplitsListView extends StatelessWidget {
  final List<KmSplit> splits;
  final double fastestPace;

  const SplitsListView({
    super.key,
    required this.splits,
    this.fastestPace = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBackground;

    if (splits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          'No splits recorded yet.',
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
        ),
      );
    }

    // Find best pace among splits for relative comparison
    final minPace = splits.fold<double>(
      splits.first.paceMinPerKm,
      (min, s) => s.paceMinPerKm < min ? s.paceMinPerKm : min,
    );

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kilometer Splits',
                style: AppTypography.headingSmall(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              Text(
                'Avg Pace & HR',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header column row
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    'KM',
                    style: AppTypography.metricLabel(
                      color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'PACE',
                    style: AppTypography.metricLabel(
                      color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    ),
                  ),
                ),
                SizedBox(
                  width: 65,
                  child: Text(
                    'TIME',
                    textAlign: TextAlign.right,
                    style: AppTypography.metricLabel(
                      color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'HR',
                    textAlign: TextAlign.right,
                    style: AppTypography.metricLabel(
                      color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Splits items
          ...splits.map((split) {
            final isFastest = (split.paceMinPerKm - minPace).abs() < 0.05;
            final paceRatio = (split.paceMinPerKm / (minPace * 1.35)).clamp(0.2, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // KM Number
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${split.kmNumber}',
                      style: AppTypography.bodyMedium(
                        color: isDark ? Colors.white : AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Pace Visual Bar + text
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: paceRatio,
                              backgroundColor: isDark
                                  ? AppColors.darkSecondarySurface
                                  : AppColors.secondarySurface,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFastest
                                    ? (isDark ? AppColors.darkMint : AppColors.primaryTeal)
                                    : (isDark
                                        ? const Color(0xFF384040)
                                        : const Color(0xFFC0CCCC)),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${split.formattedPace}/km',
                          style: AppTypography.caption(
                            color: isFastest
                                ? (isDark ? AppColors.darkMint : AppColors.primaryTeal)
                                : (isDark ? Colors.white : AppColors.primaryText),
                            fontWeight: isFastest ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration
                  SizedBox(
                    width: 65,
                    child: Text(
                      split.formattedDuration,
                      textAlign: TextAlign.right,
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                      ),
                    ),
                  ),

                  // Heart Rate
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${split.avgHeartRate} bpm',
                      textAlign: TextAlign.right,
                      style: AppTypography.caption(
                        color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
