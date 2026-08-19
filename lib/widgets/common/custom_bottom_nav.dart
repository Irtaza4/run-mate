import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Floating dark bottom navigation bar matching the Dribbble design reference
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 22),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.statCapsuleDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Left: Calendar / Activity History
          _buildNavItem(
            index: 0,
            icon: Icons.calendar_today_outlined,
            isPill: false,
          ),

          // 2. Center: Home Dashboard (with capsule border indicator)
          _buildNavItem(
            index: 1,
            icon: Icons.home_outlined,
            isPill: true,
          ),

          // 3. Right: Live Run / Runner (with circular border indicator)
          _buildNavItem(
            index: 2,
            icon: Icons.directions_run_rounded,
            isCircle: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    bool isPill = false,
    bool isCircle = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: isPill
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: isPill ? BorderRadius.circular(20) : null,
          shape: isCircle ? BoxShape.circle : (isPill ? BoxShape.rectangle : BoxShape.rectangle),
          border: (isSelected && (isPill || isCircle))
              ? Border.all(color: Colors.white, width: 1.6)
              : null,
          color: (isSelected && !isPill && !isCircle)
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
