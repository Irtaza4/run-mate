import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common/custom_bottom_nav.dart';
import 'activity_history_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'live_run_screen.dart';
import 'profile_screen.dart';

/// Main scaffold hosting the bottom navigation bar and active tab screens
class MainShellScreen extends StatefulWidget {
  final AppState state;

  const MainShellScreen({super.key, required this.state});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  SuggestedRoute? _selectedRouteForRun;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToRunScreenWithRoute(SuggestedRoute route) {
    setState(() {
      _selectedRouteForRun = route;
    });
    widget.state.setTabIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Indexed Active Tab Screen
          IndexedStack(
            index: state.currentTabIndex,
            children: [
              // Tab 0: Home Dashboard
              HomeScreen(
                state: state,
                onStartRunTap: () => state.setTabIndex(2),
                onExploreTap: () => state.setTabIndex(1),
                onProfileTap: () => state.setTabIndex(4),
              ),

              // Tab 1: Explore Screen
              ExploreScreen(
                state: state,
                onSelectRouteToRun: _navigateToRunScreenWithRoute,
              ),

              // Tab 2: Live Run Screen
              LiveRunScreen(
                state: state,
                initialRoute: _selectedRouteForRun,
              ),

              // Tab 3: Activity History Screen
              ActivityHistoryScreen(
                state: state,
              ),

              // Tab 4: Profile Screen
              ProfileScreen(
                state: state,
              ),
            ],
          ),

          // Floating Dark Bottom Navigation Capsule
          if (!state.isRunning)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNav(
                currentIndex: state.currentTabIndex,
                onTap: (index) {
                  state.setTabIndex(index);
                },
              ),
            ),
        ],
      ),
    );
  }
}
