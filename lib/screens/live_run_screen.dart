import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/common/custom_buttons.dart';
import '../widgets/maps/route_map_view.dart';
import 'run_summary_screen.dart';

/// Live Run tracking screen with quiet map, telemetry metrics, and run controls
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

class _LiveRunScreenState extends State<LiveRunScreen> {
  bool _audioCuesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = widget.state;

    // If tracking is not active, show Pre-Run setup screen
    if (!state.isTrackingActive) {
      return _buildPreRunSetupScreen(context, isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // 1. Full Screen Quiet Vector Map
          Positioned.fill(
            child: RouteMapView(
              routeCoordinates: state.liveRoutePoints,
              height: double.infinity,
              isLive: true,
              showControls: true,
            ),
          ),

          // 2. Top Status Bar Overlay (GPS, Audio, Simulation speed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // GPS pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCard.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'GPS High Accuracy',
                            style: AppTypography.caption(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // Demo Speed Multiplier Chip
                    GestureDetector(
                      onTap: () {
                        final current = state.simulationSpeedMultiplier;
                        final next = current == 1
                            ? 5
                            : (current == 5 ? 10 : 1);
                        state.setSimulationSpeed(next);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkMint
                                  : AppColors.mint)
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.speed_rounded,
                                size: 14, color: AppColors.primaryText),
                            const SizedBox(width: 4),
                            Text(
                              'Sim: ${state.simulationSpeedMultiplier}x',
                              style: AppTypography.caption(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Bottom Telemetry & Controls Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildLiveTelemetryCard(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPreRunSetupScreen(BuildContext context, bool isDark) {
    final route = widget.initialRoute ??
        (widget.state.suggestedRoutes.isNotEmpty
            ? widget.state.suggestedRoutes.first
            : null);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Ready to Run',
                style: AppTypography.headingLarge(
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select your trail, lock GPS, and hit the ground',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 20),

              // Route Preview Canvas
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: isDark
                        ? Border.all(color: AppColors.darkDivider)
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: RouteMapView(
                          routeCoordinates: route != null
                              ? route.pathCoordinates
                              : const [Offset(0.2, 0.7), Offset(0.8, 0.3)],
                          height: double.infinity,
                          showControls: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route?.name ?? 'Free Open Run',
                                      style: AppTypography.headingSmall(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      route?.location ?? 'Dynamic GPS Tracking',
                                      style: AppTypography.caption(
                                        color: isDark
                                            ? AppColors.darkMutedText
                                            : AppColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSecondarySurface
                                        : AppColors.mint.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    route != null
                                        ? '${route.distanceKm} km'
                                        : 'Free Route',
                                    style: AppTypography.caption(
                                      color: isDark
                                          ? AppColors.darkMint
                                          : AppColors.primaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Preferences toggles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _audioCuesEnabled
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_off_rounded,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.darkMutedText
                                          : AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Voice Audio Cues',
                                      style: AppTypography.caption(
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.primaryText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _audioCuesEnabled,
                                  onChanged: (val) {
                                    setState(() {
                                      _audioCuesEnabled = val;
                                    });
                                  },
                                  activeTrackColor: isDark
                                      ? AppColors.darkMint
                                      : AppColors.primaryTeal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Start Run CTA Button
              PrimaryButton(
                text: 'Start Running',
                icon: Icons.play_arrow_rounded,
                height: 58,
                onPressed: () {
                  widget.state.startRun(route: route);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveTelemetryCard(BuildContext context, bool isDark) {
    final state = widget.state;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: isDark
            ? Border.all(color: AppColors.darkDivider, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dominant Primary Metric: Distance
          Column(
            children: [
              Text(
                'DISTANCE',
                style: AppTypography.metricLabel(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    state.liveDistanceKm.toStringAsFixed(2),
                    style: AppTypography.displayLarge(
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ).copyWith(fontSize: 44, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'km',
                    style: AppTypography.headingMedium(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Secondary Telemetry Metrics (Pace, Duration, Heart Rate)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLiveMetricColumn(
                label: 'PACE',
                value: '${state.formattedLivePace}/km',
                isDark: isDark,
              ),
              _buildLiveMetricColumn(
                label: 'DURATION',
                value: state.formattedLiveDuration,
                isDark: isDark,
              ),
              _buildLiveMetricColumn(
                label: 'HEART RATE',
                value: '${state.liveHeartRate} bpm',
                icon: Icons.favorite_rounded,
                iconColor: AppColors.danger,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Control Buttons
          if (state.isRunning)
            PrimaryButton(
              text: 'Pause Run',
              icon: Icons.pause_rounded,
              height: 56,
              onPressed: () {
                state.pauseRun();
              },
            )
          else if (state.isPaused)
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Resume',
                    icon: Icons.play_arrow_rounded,
                    height: 54,
                    onPressed: () {
                      state.resumeRun();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmFinishRun(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      fixedSize: const Size.fromHeight(54),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stop_rounded, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Finish',
                          style: AppTypography.buttonText(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLiveMetricColumn({
    required String label,
    required String value,
    IconData? icon,
    Color? iconColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.metricLabel(
                color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headingSmall(
            color: isDark ? Colors.white : AppColors.primaryText,
          ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _confirmFinishRun(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Complete Your Run?',
            style: AppTypography.headingMedium(
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
          ),
          content: Text(
            'Are you sure you want to finish and save this run to your activity log?',
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTypography.caption(
                  color: isDark ? AppColors.darkMutedText : AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final completedRun = widget.state.finishRun();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => RunSummaryScreen(run: completedRun),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkMint : AppColors.primaryTeal,
                foregroundColor: AppColors.primaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Save & Finish',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
