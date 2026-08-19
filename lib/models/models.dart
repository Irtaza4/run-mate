import 'package:flutter/material.dart';

/// Represents a single kilometer split in a run
class KmSplit {
  final int kmNumber;
  final Duration duration;
  final double paceMinPerKm;
  final int avgHeartRate;
  final int elevationChangeM;

  const KmSplit({
    required this.kmNumber,
    required this.duration,
    required this.paceMinPerKm,
    required this.avgHeartRate,
    required this.elevationChangeM,
  });

  String get formattedPace {
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Represents a completed or ongoing running activity
class RunActivity {
  final String id;
  final String title;
  final DateTime date;
  final double distanceKm;
  final Duration duration;
  final double avgPaceMinPerKm;
  final int calories;
  final int avgHeartRate;
  final int maxHeartRate;
  final int elevationGainM;
  final int cadence;
  final List<KmSplit> splits;
  final List<Offset> routeCoordinates;
  final String routeName;
  final bool isPersonalRecord;

  const RunActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.distanceKm,
    required this.duration,
    required this.avgPaceMinPerKm,
    required this.calories,
    required this.avgHeartRate,
    this.maxHeartRate = 165,
    this.elevationGainM = 45,
    this.cadence = 168,
    this.splits = const [],
    this.routeCoordinates = const [],
    this.routeName = 'City Circuit',
    this.isPersonalRecord = false,
  });

  String get formattedPace {
    final minutes = avgPaceMinPerKm.floor();
    final seconds = ((avgPaceMinPerKm - minutes) * 60).round();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDistance => distanceKm.toStringAsFixed(1);
}

/// Represents a gamified running challenge
class Challenge {
  final String id;
  final String title;
  final String description;
  final double targetKm;
  final double currentKm;
  final int daysLeft;
  final bool isJoined;
  final bool isCompleted;
  final String badgeName;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKm,
    required this.currentKm,
    required this.daysLeft,
    this.isJoined = true,
    this.isCompleted = false,
    this.badgeName = '50k_badge',
  });

  double get progressRatio => (currentKm / targetKm).clamp(0.0, 1.0);
  double get remainingKm => (targetKm - currentKm).clamp(0.0, targetKm);

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    double? targetKm,
    double? currentKm,
    int? daysLeft,
    bool? isJoined,
    bool? isCompleted,
    String? badgeName,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetKm: targetKm ?? this.targetKm,
      currentKm: currentKm ?? this.currentKm,
      daysLeft: daysLeft ?? this.daysLeft,
      isJoined: isJoined ?? this.isJoined,
      isCompleted: isCompleted ?? this.isCompleted,
      badgeName: badgeName ?? this.badgeName,
    );
  }
}

/// Represents a running team mate
class TeamMember {
  final String id;
  final String name;
  final String avatarInitials;
  final Color avatarBgColor;
  final String role;
  final double weeklyKm;
  final int streakDays;
  final int totalRuns;
  final String lastActive;
  final String? avatarAssetPath;

  const TeamMember({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.avatarBgColor,
    required this.role,
    required this.weeklyKm,
    required this.streakDays,
    required this.totalRuns,
    required this.lastActive,
    this.avatarAssetPath,
  });
}

/// Represents a suggested curated running route
class SuggestedRoute {
  final String id;
  final String name;
  final String location;
  final double distanceKm;
  final int estDurationMinutes;
  final String difficulty;
  final int elevationGainM;
  final List<Offset> pathCoordinates;
  final String description;
  final String? imageAssetPath;

  const SuggestedRoute({
    required this.id,
    required this.name,
    required this.location,
    required this.distanceKm,
    required this.estDurationMinutes,
    required this.difficulty,
    required this.elevationGainM,
    required this.pathCoordinates,
    required this.description,
    this.imageAssetPath,
  });
}

/// Represents daily activity for bar charts
class DayActivity {
  final String dayLabel;
  final double distanceKm;
  final int durationMinutes;
  final bool isSelected;
  final bool isToday;

  const DayActivity({
    required this.dayLabel,
    required this.distanceKm,
    required this.durationMinutes,
    this.isSelected = false,
    this.isToday = false,
  });

  DayActivity copyWith({
    String? dayLabel,
    double? distanceKm,
    int? durationMinutes,
    bool? isSelected,
    bool? isToday,
  }) {
    return DayActivity(
      dayLabel: dayLabel ?? this.dayLabel,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isSelected: isSelected ?? this.isSelected,
      isToday: isToday ?? this.isToday,
    );
  }
}

/// Represents an unlocked achievement or milestone
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isUnlocked;
  final String? unlockedDate;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.isUnlocked = true,
    this.unlockedDate,
  });
}

enum StatIconType { steps, heartRate, calories, distance, pace }

/// Represents a pill stat metric card
class StatMetric {
  final String id;
  final String title;
  final String value;
  final String targetOrUnit;
  final String trendText;
  final bool isTrendUp;
  final double progress; // 0.0 to 1.0
  final StatIconType iconType;

  const StatMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.targetOrUnit,
    required this.trendText,
    required this.isTrendUp,
    required this.progress,
    required this.iconType,
  });
}

/// Represents an hourly block column in the stacked tile activity chart
class HourlyActivityBlock {
  final String timeLabel;
  final int tileCount;
  final bool isPeak;
  final String? peakBadgeText;
  final double distanceKm;
  final int durationMinutes;

  const HourlyActivityBlock({
    required this.timeLabel,
    required this.tileCount,
    this.isPeak = false,
    this.peakBadgeText,
    this.distanceKm = 1.2,
    this.durationMinutes = 10,
  });
}

