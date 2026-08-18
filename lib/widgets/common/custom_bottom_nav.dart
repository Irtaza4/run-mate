import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Floating dark bottom navigation bar with circular active indicator
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.darkNavigation,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.explore_rounded,
            label: 'Explore',
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.directions_run_rounded,
            label: 'Run',
            isRunButton: true,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.bar_chart_rounded,
            label: 'Activity',
          ),
          _buildNavItem(
            index: 4,
            icon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isRunButton = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isSelected ? 50 : 44,
        height: isSelected ? 50 : 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: isSelected ? 24 : 22,
          color: isSelected
              ? AppColors.primaryText
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}
