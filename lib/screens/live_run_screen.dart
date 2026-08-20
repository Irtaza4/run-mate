import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/maps/route_map_view.dart';
import 'run_summary_screen.dart';

/// Live Run tracking & Route Screen matching the Dribbble design reference
/// with realistic 60FPS continuous GPS route traversal and heartbeat telemetry.
class LiveRunScreen extends StatefulWidget {
  final AppState state;
  final SuggestedRoute? initialRoute;

  const LiveRunScreen({
    super.key,
    required this.state,
    this.initialRoute,
  });

  @override
  State<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends State<LiveRunScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartPulseController;

  @override
  void initState() {
    super.initState();

    // Heartbeat pulse rhythm (~75-120 bpm animation)
    _heartPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Auto-start simulation run if not already tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.state.isTrackingActive && mounted) {
        widget.state.startRun(route: widget.initialRoute);
      }
    });
  }

  @override
  void dispose() {
    _heartPulseController.dispose();
    if (widget.state.isRunning) {
      widget.state.pauseRun();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;

    final distanceDisplay = state.liveDistanceKm.toStringAsFixed(1);
    final hrDisplay = '${state.liveHeartRate}';
    final calDisplay = '${state.liveCalories}';
    final durationDisplay = state.formattedLiveDuration;

    final activeRoute = widget.initialRoute ??
        (state.suggestedRoutes.isNotEmpty ? state.suggestedRoutes.first : null);
    final routeCoordinates = activeRoute != null && activeRoute.pathCoordinates.isNotEmpty
        ? activeRoute.pathCoordinates
        : const [
            Offset(0.15, 0.75),
            Offset(0.32, 0.48),
            Offset(0.55, 0.62),
            Offset(0.72, 0.38),
            Offset(0.85, 0.22),
          ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // 1. Full Screen Clean Vector Map with 60FPS Live Running Engine
          Positioned.fill(
            child: RouteMapView(
              routeCoordinates: routeCoordinates,
              height: double.infinity,
              isLive: state.isRunning,
              showControls: false,
              enableGestures: true,
            ),
          ),

          // 2. Large Bold Distance Display on the left of the map ("7.2 Km")
          Positioned(
            left: 24,
            top: MediaQuery.of(context).size.height * 0.38,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    distanceDisplay,
                    style: AppTypography.displayLarge(
                      color: AppColors.primaryText,
                    ).copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Km',
                    style: AppTypography.headingSmall(
                      color: AppColors.primaryText,
                    ).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Top Metric Badges & Compass Button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row of 3 Mint Pastel Status Chips
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // 1. Heart Rate Chip with Heartbeat Animation: "95 bpm ↗"
                            _buildHeartRateChip(hrDisplay),

                            const SizedBox(width: 8),

                            // 2. Calories Chip: "375 kcal"
                            _buildMintMetricChip(
                              icon: Icons.local_fire_department_outlined,
                              label: '$calDisplay kcal',
                            ),

                            const SizedBox(width: 8),

                            // 3. Duration Chip: "105 min" / Live timer
                            _buildMintMetricChip(
                              icon: Icons.timer_outlined,
                              label: durationDisplay,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Top-Right Compass / Recenter Button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Map centered on live runner beacon'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : Colors.black.withValues(alpha: 0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.explore_outlined,
                          color: isDark ? Colors.white : AppColors.primaryText,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Right Side Elevation Profile / Progress Vertical Indicator
          Positioned(
            right: 18,
            top: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              width: 4,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 4,
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColors.primaryText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // 5. Bottom Run Control Bar (Lap, Pause/Resume, Stop/Finish)
          Positioned(
            left: 0,
            right: 0,
            bottom: 100, // positioned above the floating bottom navigation bar
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Lap / Split Button (Timer Icon)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Split logged: ${(state.liveDistanceKm).toStringAsFixed(2)} km at ${state.formattedLivePace}/km',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.divider,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.timer_outlined,
                        color: isDark ? Colors.white : AppColors.primaryText,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 2. Central Giant Pause / Resume / Start Button
                  GestureDetector(
                    onTap: () {
                      if (state.isRunning) {
                        state.pauseRun();
                      } else if (state.trackingState == RunTrackingState.paused) {
                        state.resumeRun();
                      } else {
                        // Start a fresh new run
                        state.startRun(route: widget.initialRoute);
                      }
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.statCapsuleDark,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        state.isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // 3. Stop / Finish Button
                  GestureDetector(
                    onTap: () {
                      if (!state.isTrackingActive && state.trackingState != RunTrackingState.running) {
                        return;
                      }
                      final completedRun = state.finishRun();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RunSummaryScreen(
                            run: completedRun,
                          ),
                        ),
                      ).then((_) {
                        // When returning from summary, reset ready for next run
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.divider,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.stop_rounded,
                        color: isDark ? Colors.white : AppColors.primaryText,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Heart Rate Chip with Heartbeat Animation
  Widget _buildHeartRateChip(String hrDisplay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFC7ECE6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF86E2D5).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _heartPulseController,
            builder: (context, child) {
              final scale = 1.0 + (_heartPulseController.value * 0.22);
              return Transform.scale(
                scale: scale,
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Color(0xFFE53935),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            '$hrDisplay bpm',
            style: AppTypography.caption(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ).copyWith(fontSize: 13),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.north_east_rounded,
            size: 14,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }

  // Mint Metric Chip Builder
  Widget _buildMintMetricChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFC7ECE6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF86E2D5).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primaryText,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
