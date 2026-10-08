import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_mate/main.dart';
import 'package:run_mate/models/models.dart';
import 'package:run_mate/screens/main_shell_screen.dart';
import 'package:run_mate/widgets/cards/stacked_stat_cards_carousel.dart';
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

      // Verify Home Screen is rendered with new widgets
      expect(find.text('Hello, Julia'), findsOneWidget);
      expect(find.text("Let's train!"), findsOneWidget);
      expect(find.text('Check your stats'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Your Activity'), findsOneWidget);
      expect(find.text('Better result'), findsOneWidget);
      expect(find.text('9839'), findsOneWidget);
      expect(find.text('72'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    test('Stat timeframe filtering updates AppState statMetrics', () {
      final state = AppState();
      expect(state.statTimeframe, 'Day');
      expect(state.statMetrics.first.value, '9839');

      state.setStatTimeframe('W');
      expect(state.statTimeframe, 'W');
      expect(state.statMetrics.first.value, '54.2k');

      state.setStatTimeframe('M');
      expect(state.statTimeframe, 'M');
      expect(state.statMetrics.first.value, '238k');

      state.setStatTimeframe('Y');
      expect(state.statTimeframe, 'Y');
      expect(state.statMetrics.first.value, '2.8M');
    });

    testWidgets('Explore and adjust screen renders challenge, team, and map cards', (WidgetTester tester) async {
      final state = AppState();
      state.setTabIndex(3); // Explore screen

      await tester.pumpWidget(
        MaterialApp(
          home: MainShellScreen(state: state),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Explore and adjust'), findsOneWidget);
      expect(find.text('Running Challenge'), findsOneWidget);
      expect(find.text('43/90 days'), findsOneWidget);
      expect(find.text('Your Team'), findsOneWidget);
      expect(find.text('Nika'), findsOneWidget);
      expect(find.text('View on the map'), findsOneWidget);
      expect(find.text('One Sino Park'), findsOneWidget);

      state.pauseRun();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('StackedStatCardsCarousel renders 3D deck and allows swiping cards', (WidgetTester tester) async {
      final state = AppState();
      state.setTabIndex(1); // Home Dashboard

      await tester.pumpWidget(
        MaterialApp(
          home: MainShellScreen(state: state),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Active card Steps is visible
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('9839'), findsOneWidget);

      // Drag carousel to reveal next cards in deck
      await tester.drag(find.byType(StackedStatCardsCarousel), const Offset(-200, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Heart Rate'), findsOneWidget);

      state.pauseRun();
      await tester.pumpWidget(const SizedBox());
    });
  });
}


