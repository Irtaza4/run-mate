import 'package:flutter_test/flutter_test.dart';
import 'package:run_mate/main.dart';
import 'package:run_mate/models/models.dart';
import 'package:run_mate/state/app_state.dart';

void main() {
  group('AppState Core Logic & Simulation Tests', () {
    test('Initial AppState contains default challenges, routes, and history', () {
      final state = AppState();
      expect(state.userName, 'Julia');
      expect(state.challenges.isNotEmpty, true);
      expect(state.teamMembers.isNotEmpty, true);
      expect(state.suggestedRoutes.isNotEmpty, true);
      expect(state.runHistory.isNotEmpty, true);
      expect(state.achievements.isNotEmpty, true);
    });

    test('Starting a run initializes telemetry and changes tracking state', () {
      final state = AppState();
      expect(state.trackingState, RunTrackingState.stopped);

      state.startRun();
      expect(state.trackingState, RunTrackingState.running);
      expect(state.isRunning, true);
      expect(state.liveRoutePoints.isNotEmpty, true);

      state.pauseRun();
      expect(state.trackingState, RunTrackingState.paused);
      expect(state.isPaused, true);

      state.resumeRun();
      expect(state.trackingState, RunTrackingState.running);

      final finishedRun = state.finishRun();
      expect(finishedRun.distanceKm >= 0, true);
      expect(state.runHistory.first.id, finishedRun.id);
      expect(state.trackingState, RunTrackingState.stopped);
    });

    test('KmSplit pace formatting works correctly', () {
      const split = KmSplit(
        kmNumber: 1,
        duration: Duration(minutes: 5, seconds: 32),
        paceMinPerKm: 5.5333,
        avgHeartRate: 135,
        elevationChangeM: 8,
      );
      expect(split.formattedDuration, '5:32');
      expect(split.formattedPace, '5:32');
    });

    test('Challenge progress ratio calculation works correctly', () {
      const challenge = Challenge(
        id: 'ch_test',
        title: 'Test Challenge',
        description: 'Run 50 km',
        targetKm: 50.0,
        currentKm: 25.0,
        daysLeft: 10,
      );
      expect(challenge.progressRatio, 0.5);
      expect(challenge.remainingKm, 25.0);
    });

    test('Theme toggle updates dark mode state', () {
      final state = AppState();
      expect(state.isDarkMode, false);
      state.toggleDarkMode();
      expect(state.isDarkMode, true);
      state.toggleDarkMode();
      expect(state.isDarkMode, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('RunMate smoke test: Onboarding and navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const RunMateApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify onboarding screen is shown
      expect(find.text('RunMate'), findsOneWidget);
      expect(find.text('Simplicity in Motion'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Tap Skip to go to MainShellScreen
      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Home Screen is rendered
      expect(find.text('Hello, Julia'), findsOneWidget);
      expect(find.text("Today's Statistics"), findsOneWidget);
      expect(find.text('DISTANCE'), findsWidgets);
    });
  });
}
