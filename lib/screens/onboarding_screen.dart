import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/custom_buttons.dart';

/// Clean, lightweight onboarding flow for RunMate
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedGoal = '25 km / week';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top header with Skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkMint : AppColors.mint,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_run_rounded,
                          size: 20,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RunMate',
                        style: AppTypography.headingMedium(
                          color: isDark ? Colors.white : AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: widget.onFinish,
                      child: Text(
                        'Skip',
                        style: AppTypography.caption(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Page Views
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildSlideOne(isDark),
                    _buildSlideTwo(isDark),
                    _buildSlideThree(isDark),
                  ],
                ),
              ),

              // Bottom Indicator & CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? (isDark ? AppColors.darkMint : AppColors.primaryTeal)
                              : (isDark
                                  ? AppColors.darkSecondarySurface
                                  : AppColors.secondarySurface),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Button
                  SizedBox(
                    width: 150,
                    child: PrimaryButton(
                      text: _currentPage == 2 ? 'Get Started' : 'Continue',
                      onPressed: _nextPage,
                      height: 52,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideOne(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decorative Hero Graphic Card
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2625) : const Color(0xFFD8F0EC),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric soft circles
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mint.withValues(alpha: isDark ? 0.15 : 0.45),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTeal.withValues(alpha: isDark ? 0.3 : 0.6),
                ),
              ),
              const Icon(
                Icons.directions_run_rounded,
                size: 64,
                color: AppColors.primaryText,
              ),
              Positioned(
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on_rounded,
                          size: 16, color: AppColors.primaryTeal),
                      const SizedBox(width: 6),
                      Text(
                        '7.2 km  •  5:24 /km',
                        style: AppTypography.caption(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        Text(
          'Simplicity in Motion',
          textAlign: TextAlign.center,
          style: AppTypography.headingLarge(
            color: isDark ? Colors.white : AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your running data made clear, motivating, and actionable. Track distances, pace, routes, and personal bests without clutter.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildSlideTwo(bool isDark) {
    final goals = [
      '15 km / week (Beginner)',
      '25 km / week (Active)',
      '40 km / week (Marathoner)',
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Set Your Running Goal',
          textAlign: TextAlign.center,
          style: AppTypography.headingLarge(
            color: isDark ? Colors.white : AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Choose your target weekly mileage to personalize your dashboard and challenge milestones.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 32),

        // Goal options
        ...goals.map((goal) {
          final isSelected = _selectedGoal == goal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGoal = goal;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF1B2A27) : AppColors.mint)
                      : (isDark ? AppColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.darkMint : AppColors.primaryTeal)
                        : (isDark ? AppColors.darkDivider : AppColors.divider),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal,
                      style: AppTypography.bodyLarge(
                        color: isDark ? Colors.white : AppColors.primaryText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isSelected
                          ? (isDark ? AppColors.darkMint : AppColors.primaryText)
                          : (isDark ? AppColors.darkMutedText : AppColors.mutedText),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSlideThree(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkMint : AppColors.mint,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.location_on_rounded,
            size: 44,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Real-time GPS Tracking',
          textAlign: TextAlign.center,
          style: AppTypography.headingLarge(
            color: isDark ? Colors.white : AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'RunMate maps your routes with quiet aesthetics, instant pace updates, heart rate tracking, and team motivation.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isDark
                ? Border.all(color: AppColors.darkDivider)
                : null,
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined,
                  size: 20, color: AppColors.primaryTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Location data is kept private on device',
                  style: AppTypography.caption(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
