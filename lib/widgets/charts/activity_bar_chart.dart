import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Lightweight rounded vertical-bar activity visualization
class ActivityBarChart extends StatefulWidget {
  final List<DayActivity> activities;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int> onDaySelected;

  const ActivityBarChart({
    super.key,
    required this.activities,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onDaySelected,
  });

  @override
  State<ActivityBarChart> createState() => _ActivityBarChartState();
}

class _ActivityBarChartState extends State<ActivityBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant ActivityBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeFilter != widget.activeFilter ||
        oldWidget.activities != widget.activities) {
      _animController.reset();
      _animController.forward();
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
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBackground;

    // Find max value to normalize height
    double maxDistance = widget.activities.fold(
      1.0,
      (max, item) => item.distanceKm > max ? item.distanceKm : max,
    );
    if (maxDistance == 0) maxDistance = 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
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
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Filter Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity'.toUpperCase(),
                    style: AppTypography.metricLabel(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weekly Performance',
                    style: AppTypography.headingSmall(
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              _buildFilterCapsule(isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Selected bar info tooltip
          _buildActiveInfoBanner(isDark),
          const SizedBox(height: 16),

          // Chart Bars Canvas
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(widget.activities.length, (index) {
                    final item = widget.activities[index];
                    final normalizedHeight =
                        (item.distanceKm / maxDistance) * _scaleAnimation.value;
                    final isSelected = item.isSelected || _hoveredIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _hoveredIndex = index;
                          });
                          widget.onDaySelected(index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Interactive Bar
                            Expanded(
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  width: 28,
                                  height: (100 * normalizedHeight).clamp(12.0, 100.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? AppColors.darkMint : AppColors.primaryTeal)
                                        : (isDark
                                            ? AppColors.darkSecondarySurface
                                            : AppColors.secondarySurface),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: (isDark
                                                      ? AppColors.darkMint
                                                      : AppColors.primaryTeal)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Day Label
                            Text(
                              item.dayLabel,
                              style: AppTypography.caption(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.darkPrimaryText
                                        : AppColors.primaryText)
                                    : (isDark
                                        ? AppColors.darkMutedText
                                        : AppColors.mutedText),
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCapsule(bool isDark) {
    const filters = ['Day', 'Week', 'Month'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondarySurface
            : AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((f) {
          final isSelected = widget.activeFilter == f;
          return GestureDetector(
            onTap: () => widget.onFilterChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkCard : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected && !isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                f,
                style: AppTypography.caption(
                  color: isSelected
                      ? (isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText)
                      : (isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ).copyWith(fontSize: 11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveInfoBanner(bool isDark) {
    final selectedItem = widget.activities.firstWhere(
      (item) => item.isSelected,
      orElse: () => widget.activities.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSecondarySurface.withValues(alpha: 0.6)
            : AppColors.mint.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${selectedItem.dayLabel} Activity',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${selectedItem.distanceKm.toStringAsFixed(1)} km',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '• ${selectedItem.durationMinutes} min',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
