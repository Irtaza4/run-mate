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
          ),

          // 2. Center: Home Dashboard
          _buildNavItem(
            index: 1,
            icon: Icons.home_outlined,
          ),

          // 3. Right: Live Run / Runner
          _buildNavItem(
            index: 2,
            icon: Icons.directions_run_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.white, width: 1.6)
              : Border.all(color: Colors.transparent, width: 1.6),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
