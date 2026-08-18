import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

enum RunTrackingState { stopped, running, paused, finished }

/// Reactive Central State for RunMate
class AppState extends ChangeNotifier {
  AppState() {
    _initializeData();
  }

  // --- Theme & Navigation ---
  bool _isDarkMode = false;
  int _currentTabIndex = 0;

  bool get isDarkMode => _isDarkMode;
  int get currentTabIndex => _currentTabIndex;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- User Profile ---
  String userName = 'Julia';
  String userFullTitle = 'Julia Smith';
  String userBio = 'Runner since 2026';
  double totalDistanceKm = 324.8;
  int totalRuns = 47;
  String bestPace = '4:52 /km';
  int currentStreakDays = 6;
  double weeklyGoalKm = 25.0;
  double monthlyGoalKm = 100.0;

  // --- Live Run Tracking Engine ---
  RunTrackingState _trackingState = RunTrackingState.stopped;
  Duration _liveDuration = Duration.zero;
  double _liveDistanceKm = 0.0;
  double _livePace = 5.24; // min per km
  int _liveHeartRate = 138;
  int _liveCalories = 0;
  int _liveCadence = 168;
  int _liveElevationGain = 0;
  int _simulationSpeedMultiplier = 1; // 1x or 5x or 10x for live demo
  SuggestedRoute? _selectedRoute;

  final List<Offset> _liveRoutePoints = [];
  final List<KmSplit> _liveSplits = [];
  Timer? _runTicker;
  final Random _rnd = Random();

  RunTrackingState get trackingState => _trackingState;
  Duration get liveDuration => _liveDuration;
  double get liveDistanceKm => _liveDistanceKm;
  double get livePace => _livePace;
  int get liveHeartRate => _liveHeartRate;
  int get liveCalories => _liveCalories;
  int get liveCadence => _liveCadence;
  int get liveElevationGain => _liveElevationGain;
  int get simulationSpeedMultiplier => _simulationSpeedMultiplier;
  SuggestedRoute? get selectedRoute => _selectedRoute;
  List<Offset> get liveRoutePoints => List.unmodifiable(_liveRoutePoints);
  List<KmSplit> get liveSplits => List.unmodifiable(_liveSplits);

  bool get isRunning => _trackingState == RunTrackingState.running;
  bool get isPaused => _trackingState == RunTrackingState.paused;
  bool get isTrackingActive =>
      _trackingState == RunTrackingState.running ||
      _trackingState == RunTrackingState.paused;

  String get formattedLiveDuration {
    final minutes = _liveDuration.inMinutes;
    final seconds = _liveDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedLivePace {
    final minutes = _livePace.floor();
    final seconds = ((_livePace - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void setSimulationSpeed(int multiplier) {
    _simulationSpeedMultiplier = multiplier;
    notifyListeners();
  }

  void startRun({SuggestedRoute? route}) {
    _selectedRoute = route;
    _trackingState = RunTrackingState.running;
    _liveDuration = Duration.zero;
    _liveDistanceKm = 0.0;
    _livePace = 5.30;
    _liveHeartRate = 126;
    _liveCalories = 0;
    _liveElevationGain = 0;
    _liveCadence = 165;
    _liveRoutePoints.clear();
    _liveSplits.clear();

    // Start at route initial coordinate or center
    final startPoint = route != null && route.pathCoordinates.isNotEmpty
        ? route.pathCoordinates.first
        : const Offset(0.2, 0.7);
    _liveRoutePoints.add(startPoint);

    _startTimer();
    notifyListeners();
  }

  void pauseRun() {
    if (_trackingState == RunTrackingState.running) {
      _trackingState = RunTrackingState.paused;
      _runTicker?.cancel();
      notifyListeners();
    }
  }

  void resumeRun() {
    if (_trackingState == RunTrackingState.paused) {
      _trackingState = RunTrackingState.running;
      _startTimer();
      notifyListeners();
    }
  }

  void _startTimer() {
    _runTicker?.cancel();
    _runTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (_trackingState != RunTrackingState.running) return;

    final stepSeconds = _simulationSpeedMultiplier;
    _liveDuration += Duration(seconds: stepSeconds);

    // Speed calculation: ~10-12 km/h (approx 2.8 - 3.2 m/s)
    final deltaKm = (0.0031 + (_rnd.nextDouble() * 0.0006 - 0.0003)) * stepSeconds;
    _liveDistanceKm += deltaKm;

    // Pace variance
    final currentInstantPace = (5.10 + (_rnd.nextDouble() * 0.4 - 0.2));
    _livePace = (_livePace * 0.85) + (currentInstantPace * 0.15);

    // Heart Rate variance
    final targetHr = 135 + (_liveDistanceKm * 3.5).toInt().clamp(0, 30);
    _liveHeartRate = (targetHr + (_rnd.nextInt(5) - 2)).clamp(115, 178);

    // Calories: approx 65-70 kcal/km
    _liveCalories = (_liveDistanceKm * 68).round();

    // Cadence
    _liveCadence = 166 + (_rnd.nextInt(5) - 2);

    // Elevation
    _liveElevationGain = (_liveDistanceKm * 6.2).round();

    // Advance GPS breadcrumbs along route
    _advanceRouteCoordinates();

    // Check kilometer split triggers
    final completedKmCount = _liveDistanceKm.floor();
    if (completedKmCount > _liveSplits.length) {
      final splitNum = _liveSplits.length + 1;
      final splitDuration = Duration(seconds: (_livePace * 60).round());
      _liveSplits.add(KmSplit(
        kmNumber: splitNum,
        duration: splitDuration,
        paceMinPerKm: _livePace,
        avgHeartRate: _liveHeartRate - 4,
        elevationChangeM: 6 + _rnd.nextInt(8),
      ));
    }

    notifyListeners();
  }

  void _advanceRouteCoordinates() {
    if (_selectedRoute != null && _selectedRoute!.pathCoordinates.isNotEmpty) {
      final totalCoords = _selectedRoute!.pathCoordinates;
      final routeRatio = (_liveDistanceKm / _selectedRoute!.distanceKm).clamp(0.0, 1.0);
      final targetIndex = (routeRatio * (totalCoords.length - 1)).floor();
      if (targetIndex >= _liveRoutePoints.length && targetIndex < totalCoords.length) {
        _liveRoutePoints.add(totalCoords[targetIndex]);
      }
    } else {
      // Procedural scenic path generation
      final lastPoint = _liveRoutePoints.isNotEmpty
          ? _liveRoutePoints.last
          : const Offset(0.2, 0.7);
      final angle = (sin(_liveDuration.inSeconds * 0.05) * 0.6) - 0.2;
      final stepLen = 0.004 * _simulationSpeedMultiplier;
      final nextX = (lastPoint.dx + cos(angle) * stepLen).clamp(0.08, 0.92);
      final nextY = (lastPoint.dy + sin(angle) * stepLen).clamp(0.08, 0.92);
      _liveRoutePoints.add(Offset(nextX, nextY));
    }
  }

  RunActivity finishRun() {
    _runTicker?.cancel();
    _trackingState = RunTrackingState.finished;

    // Build final run activity
    final runTitle = _selectedRoute != null ? _selectedRoute!.name : 'Evening City Run';
    final completedRun = RunActivity(
      id: 'run_${DateTime.now().millisecondsSinceEpoch}',
      title: runTitle,
      date: DateTime.now(),
      distanceKm: _liveDistanceKm > 0 ? _liveDistanceKm : 7.2,
      duration: _liveDuration.inSeconds > 10 ? _liveDuration : const Duration(minutes: 42, seconds: 18),
      avgPaceMinPerKm: _livePace,
      calories: _liveCalories > 0 ? _liveCalories : 512,
      avgHeartRate: _liveHeartRate,
      maxHeartRate: _liveHeartRate + 22,
      elevationGainM: _liveElevationGain > 0 ? _liveElevationGain : 48,
      cadence: _liveCadence,
      splits: _liveSplits.isNotEmpty ? List.from(_liveSplits) : _generateDefaultSplits(),
      routeCoordinates: _liveRoutePoints.isNotEmpty ? List.from(_liveRoutePoints) : _defaultRoutePoints,
      routeName: _selectedRoute?.name ?? 'One River Park',
      isPersonalRecord: _liveDistanceKm > 10.0,
    );

    // Add to activity history
    _runHistory.insert(0, completedRun);

    // Update profile totals
    totalDistanceKm += completedRun.distanceKm;
    totalRuns += 1;

    // Update challenge progress
    if (_challenges.isNotEmpty && _challenges[0].isJoined) {
      final ch = _challenges[0];
      final newCurrent = (ch.currentKm + completedRun.distanceKm).clamp(0.0, ch.targetKm);
      _challenges[0] = ch.copyWith(
        currentKm: newCurrent,
        isCompleted: newCurrent >= ch.targetKm,
      );
    }

    _trackingState = RunTrackingState.stopped;
    notifyListeners();
    return completedRun;
  }

  void discardRun() {
    _runTicker?.cancel();
    _trackingState = RunTrackingState.stopped;
    _liveDuration = Duration.zero;
    _liveDistanceKm = 0.0;
    _liveRoutePoints.clear();
    _liveSplits.clear();
    notifyListeners();
  }

  // --- Activity Chart Data ---
  String _chartFilter = 'Week'; // 'Day', 'Week', 'Month', 'Year'
  int _selectedDayIndex = 3; // Thursday by default

  String get chartFilter => _chartFilter;
  int get selectedDayIndex => _selectedDayIndex;

  List<DayActivity> _weekActivities = [];
  List<DayActivity> get weekActivities => _weekActivities;

  void setChartFilter(String filter) {
    _chartFilter = filter;
    _buildActivitiesForFilter(filter);
    notifyListeners();
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    for (int i = 0; i < _weekActivities.length; i++) {
      _weekActivities[i] = _weekActivities[i].copyWith(isSelected: i == index);
    }
    notifyListeners();
  }

  void _buildActivitiesForFilter(String filter) {
    if (filter == 'Week') {
      _weekActivities = [
        const DayActivity(dayLabel: 'Mon', distanceKm: 4.2, durationMinutes: 24),
        const DayActivity(dayLabel: 'Tue', distanceKm: 6.5, durationMinutes: 38),
        const DayActivity(dayLabel: 'Wed', distanceKm: 8.8, durationMinutes: 52),
        const DayActivity(dayLabel: 'Thu', distanceKm: 7.2, durationMinutes: 42, isSelected: true, isToday: true),
        const DayActivity(dayLabel: 'Fri', distanceKm: 3.1, durationMinutes: 18),
        const DayActivity(dayLabel: 'Sat', distanceKm: 11.4, durationMinutes: 66),
        const DayActivity(dayLabel: 'Sun', distanceKm: 9.0, durationMinutes: 54),
      ];
    } else if (filter == 'Month') {
      _weekActivities = [
        const DayActivity(dayLabel: 'W1', distanceKm: 28.5, durationMinutes: 160),
        const DayActivity(dayLabel: 'W2', distanceKm: 34.2, durationMinutes: 195),
        const DayActivity(dayLabel: 'W3', distanceKm: 42.0, durationMinutes: 240, isSelected: true),
        const DayActivity(dayLabel: 'W4', distanceKm: 38.6, durationMinutes: 215, isToday: true),
      ];
    } else if (filter == 'Day') {
      _weekActivities = [
        const DayActivity(dayLabel: '6 AM', distanceKm: 2.0, durationMinutes: 12),
        const DayActivity(dayLabel: '9 AM', distanceKm: 0.0, durationMinutes: 0),
        const DayActivity(dayLabel: '12 PM', distanceKm: 1.5, durationMinutes: 9),
        const DayActivity(dayLabel: '3 PM', distanceKm: 0.0, durationMinutes: 0),
        const DayActivity(dayLabel: '6 PM', distanceKm: 5.2, durationMinutes: 30, isSelected: true, isToday: true),
        const DayActivity(dayLabel: '9 PM', distanceKm: 0.0, durationMinutes: 0),
      ];
    } else {
      // Year
      _weekActivities = [
        const DayActivity(dayLabel: 'Jan', distanceKm: 85, durationMinutes: 480),
        const DayActivity(dayLabel: 'Feb', distanceKm: 92, durationMinutes: 510),
        const DayActivity(dayLabel: 'Mar', distanceKm: 115, durationMinutes: 640),
        const DayActivity(dayLabel: 'Apr', distanceKm: 104, durationMinutes: 590),
        const DayActivity(dayLabel: 'May', distanceKm: 128, durationMinutes: 720, isSelected: true, isToday: true),
        const DayActivity(dayLabel: 'Jun', distanceKm: 98, durationMinutes: 540),
      ];
    }
  }

  // --- Challenges ---
  final List<Challenge> _challenges = [];
  List<Challenge> get challenges => List.unmodifiable(_challenges);

  void toggleJoinChallenge(String id) {
    final idx = _challenges.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _challenges[idx] = _challenges[idx].copyWith(isJoined: !_challenges[idx].isJoined);
      notifyListeners();
    }
  }

  // --- Team Members ---
  final List<TeamMember> _teamMembers = [];
  List<TeamMember> get teamMembers => List.unmodifiable(_teamMembers);

  // --- Suggested Routes ---
  final List<SuggestedRoute> _suggestedRoutes = [];
  List<SuggestedRoute> get suggestedRoutes => List.unmodifiable(_suggestedRoutes);

  // --- Run History ---
  final List<RunActivity> _runHistory = [];
  List<RunActivity> get runHistory => List.unmodifiable(_runHistory);

  // --- Achievements ---
  final List<Achievement> _achievements = [];
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  // --- Initialization ---
  void _initializeData() {
    _buildActivitiesForFilter('Week');

    _challenges.addAll([
      const Challenge(
        id: 'ch_1',
        title: 'Running Challenge',
        description: 'Run 50 km this month',
        targetKm: 50.0,
        currentKm: 43.0,
        daysLeft: 5,
        isJoined: true,
        isCompleted: false,
      ),
      const Challenge(
        id: 'ch_2',
        title: 'Spring Half-Marathon Prep',
        description: 'Log 21.1 km cumulative distance this week',
        targetKm: 21.1,
        currentKm: 18.4,
        daysLeft: 2,
        isJoined: true,
        isCompleted: false,
      ),
      const Challenge(
        id: 'ch_3',
        title: 'Weekend 10K Streak',
        description: 'Complete 10 km over Saturday and Sunday',
        targetKm: 10.0,
        currentKm: 10.0,
        daysLeft: 0,
        isJoined: true,
        isCompleted: true,
      ),
      const Challenge(
        id: 'ch_4',
        title: 'Morning Early Birds',
        description: 'Run 5 sessions before 8:00 AM',
        targetKm: 5.0,
        currentKm: 3.0,
        daysLeft: 8,
        isJoined: false,
        isCompleted: false,
      ),
    ]);

    _teamMembers.addAll([
      const TeamMember(
        id: 'tm_1',
        name: 'Marcus Vance',
        avatarInitials: 'MV',
        avatarBgColor: Color(0xFF65C7A7),
        role: 'Pace Leader',
        weeklyKm: 38.4,
        streakDays: 14,
        totalRuns: 62,
        lastActive: '2h ago',
      ),
      const TeamMember(
        id: 'tm_2',
        name: 'Elena Rostova',
        avatarInitials: 'ER',
        avatarBgColor: Color(0xFF77CFC3),
        role: 'Marathoner',
        weeklyKm: 46.2,
        streakDays: 21,
        totalRuns: 89,
        lastActive: '5h ago',
      ),
      const TeamMember(
        id: 'tm_3',
        name: 'Leo Kim',
        avatarInitials: 'LK',
        avatarBgColor: Color(0xFFF2C76B),
        role: 'Sprinter',
        weeklyKm: 22.8,
        streakDays: 4,
        totalRuns: 31,
        lastActive: 'Yesterday',
      ),
      const TeamMember(
        id: 'tm_4',
        name: 'Sophie Dubois',
        avatarInitials: 'SD',
        avatarBgColor: Color(0xFFEA7777),
        role: 'Trail Runner',
        weeklyKm: 31.5,
        streakDays: 8,
        totalRuns: 54,
        lastActive: '1d ago',
      ),
    ]);

    _suggestedRoutes.addAll([
      SuggestedRoute(
        id: 'rt_1',
        name: 'One River Park',
        location: 'Downtown Waterfront',
        distanceKm: 7.2,
        estDurationMinutes: 42,
        difficulty: 'Easy',
        elevationGainM: 34,
        pathCoordinates: _riverParkCoordinates,
        description: 'Scenic flat riverside trail with fresh morning breeze and dedicated pedestrian lanes.',
      ),
      SuggestedRoute(
        id: 'rt_2',
        name: 'Skyline Ridge Loop',
        location: 'North Park Heights',
        distanceKm: 10.5,
        estDurationMinutes: 60,
        difficulty: 'Moderate',
        elevationGainM: 115,
        pathCoordinates: _skylineRidgeCoordinates,
        description: 'Sweeping city skyline panoramas with moderate rolling hills and smooth asphalt.',
      ),
      SuggestedRoute(
        id: 'rt_3',
        name: 'Harbor Breeze Sprint',
        location: 'Marina Promenade',
        distanceKm: 5.0,
        estDurationMinutes: 28,
        difficulty: 'Easy',
        elevationGainM: 12,
        pathCoordinates: _harborSprintCoordinates,
        description: 'Fast and flat coastal course ideal for tempo intervals and 5K personal records.',
      ),
      SuggestedRoute(
        id: 'rt_4',
        name: 'Pine Hill Trail',
        location: 'Cedar Forest Reserve',
        distanceKm: 8.4,
        estDurationMinutes: 54,
        difficulty: 'Challenging',
        elevationGainM: 185,
        pathCoordinates: _pineHillCoordinates,
        description: 'Invigorating gravel forest switchbacks shaded by tall pines with rewarding elevation climb.',
      ),
    ]);

    // Pre-populate realistic Run History
    _runHistory.addAll([
      RunActivity(
        id: 'run_hist_1',
        title: 'One River Park Morning Run',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        distanceKm: 7.2,
        duration: const Duration(minutes: 42, seconds: 18),
        avgPaceMinPerKm: 5.867, // 5:52
        calories: 512,
        avgHeartRate: 138,
        maxHeartRate: 164,
        elevationGainM: 45,
        cadence: 168,
        splits: _generateSampleSplits(7, 5.86),
        routeCoordinates: _riverParkCoordinates,
        routeName: 'One River Park',
        isPersonalRecord: false,
      ),
      RunActivity(
        id: 'run_hist_2',
        title: 'Harbor Sunset Tempo',
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        distanceKm: 5.4,
        duration: const Duration(minutes: 31, seconds: 20),
        avgPaceMinPerKm: 5.8, // 5:48
        calories: 395,
        avgHeartRate: 144,
        maxHeartRate: 172,
        elevationGainM: 18,
        cadence: 172,
        splits: _generateSampleSplits(5, 5.8),
        routeCoordinates: _harborSprintCoordinates,
        routeName: 'Harbor Breeze Sprint',
        isPersonalRecord: true,
      ),
      RunActivity(
        id: 'run_hist_3',
        title: 'Skyline Ridge Long Run',
        date: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        distanceKm: 8.1,
        duration: const Duration(minutes: 47, seconds: 42),
        avgPaceMinPerKm: 5.883, // 5:53
        calories: 610,
        avgHeartRate: 141,
        maxHeartRate: 168,
        elevationGainM: 88,
        cadence: 166,
        splits: _generateSampleSplits(8, 5.88),
        routeCoordinates: _skylineRidgeCoordinates,
        routeName: 'Skyline Ridge Loop',
        isPersonalRecord: false,
      ),
      RunActivity(
        id: 'run_hist_4',
        title: 'City Park Recovery Jog',
        date: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
        distanceKm: 4.5,
        duration: const Duration(minutes: 27, seconds: 50),
        avgPaceMinPerKm: 6.18, // 6:11
        calories: 320,
        avgHeartRate: 129,
        maxHeartRate: 148,
        elevationGainM: 22,
        cadence: 162,
        splits: _generateSampleSplits(4, 6.18),
        routeCoordinates: _riverParkCoordinates,
        routeName: 'City Circuit',
        isPersonalRecord: false,
      ),
    ]);

    // Achievements
    _achievements.addAll([
      const Achievement(
        id: 'ach_1',
        title: 'First 10K',
        description: 'Completed your first 10 km run in under 60 minutes',
        icon: Icons.emoji_events_rounded,
        iconColor: Color(0xFFF2C76B),
        isUnlocked: true,
        unlockedDate: 'May 12, 2026',
      ),
      const Achievement(
        id: 'ach_2',
        title: 'Early Bird',
        description: 'Finished 5 runs before 7:00 AM in a single month',
        icon: Icons.wb_sunny_rounded,
        iconColor: Color(0xFF77CFC3),
        isUnlocked: true,
        unlockedDate: 'May 18, 2026',
      ),
      const Achievement(
        id: 'ach_3',
        title: 'Streak Master',
        description: 'Maintained a 7-day daily activity streak',
        icon: Icons.local_fire_department_rounded,
        iconColor: Color(0xFFEA7777),
        isUnlocked: true,
        unlockedDate: 'June 01, 2026',
      ),
      const Achievement(
        id: 'ach_4',
        title: 'Elevation Climber',
        description: 'Accumulated over 1,000m total elevation gain',
        icon: Icons.terrain_rounded,
        iconColor: Color(0xFF65C7A7),
        isUnlocked: false,
      ),
      const Achievement(
        id: 'ach_5',
        title: 'Speed Demon',
        description: 'Logged a sub-5:00 /km pace for at least 5 km',
        icon: Icons.flash_on_rounded,
        iconColor: Color(0xFFF2C76B),
        isUnlocked: true,
        unlockedDate: 'June 10, 2026',
      ),
      const Achievement(
        id: 'ach_6',
        title: 'Marathon Legend',
        description: 'Complete 42.2 km cumulative distance in 2 weeks',
        icon: Icons.military_tech_rounded,
        iconColor: Color(0xFF77CFC3),
        isUnlocked: false,
      ),
    ]);
  }

  static List<KmSplit> _generateSampleSplits(int count, double basePace) {
    final list = <KmSplit>[];
    for (int i = 1; i <= count; i++) {
      final variance = (sin(i * 1.3) * 0.2);
      final pace = (basePace + variance).clamp(4.8, 6.8);
      final duration = Duration(seconds: (pace * 60).round());
      list.add(KmSplit(
        kmNumber: i,
        duration: duration,
        paceMinPerKm: pace,
        avgHeartRate: 132 + (i * 2),
        elevationChangeM: 4 + (i % 3) * 4,
      ));
    }
    return list;
  }

  static List<KmSplit> _generateDefaultSplits() {
    return _generateSampleSplits(7, 5.86);
  }

  // Pre-calculated normalized route paths for smooth canvas rendering
  static const List<Offset> _riverParkCoordinates = [
    Offset(0.18, 0.78),
    Offset(0.24, 0.65),
    Offset(0.35, 0.58),
    Offset(0.48, 0.62),
    Offset(0.60, 0.48),
    Offset(0.72, 0.35),
    Offset(0.82, 0.26),
    Offset(0.78, 0.18),
    Offset(0.62, 0.22),
    Offset(0.48, 0.32),
    Offset(0.34, 0.45),
    Offset(0.22, 0.60),
    Offset(0.18, 0.78),
  ];

  static const List<Offset> _skylineRidgeCoordinates = [
    Offset(0.25, 0.82),
    Offset(0.38, 0.72),
    Offset(0.52, 0.78),
    Offset(0.68, 0.64),
    Offset(0.82, 0.52),
    Offset(0.75, 0.34),
    Offset(0.58, 0.22),
    Offset(0.42, 0.28),
    Offset(0.30, 0.46),
    Offset(0.22, 0.66),
    Offset(0.25, 0.82),
  ];

  static const List<Offset> _harborSprintCoordinates = [
    Offset(0.15, 0.30),
    Offset(0.32, 0.35),
    Offset(0.48, 0.42),
    Offset(0.65, 0.55),
    Offset(0.78, 0.68),
    Offset(0.85, 0.80),
  ];

  static const List<Offset> _pineHillCoordinates = [
    Offset(0.20, 0.85),
    Offset(0.35, 0.75),
    Offset(0.28, 0.60),
    Offset(0.45, 0.48),
    Offset(0.38, 0.35),
    Offset(0.55, 0.24),
    Offset(0.72, 0.28),
    Offset(0.82, 0.42),
    Offset(0.70, 0.62),
    Offset(0.52, 0.78),
    Offset(0.20, 0.85),
  ];

  static const List<Offset> _defaultRoutePoints = _riverParkCoordinates;
}
