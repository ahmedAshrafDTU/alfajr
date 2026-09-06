enum HabitStatus {
  newHabit,     // < 7 days
  training,     // 7-20 days
  developing,   // 21-40 days
  stable,       // 40+ days
  struggling,   // Was stable/developing but completion rate dropped recently
}

class Habit {
  final String wirdId;
  final HabitStatus status;
  final int currentStreak;
  final int longestStreak;
  final double completionRateLast30Days;
  final int activeDays; // Total days the user interacted with this habit

  Habit({
    required this.wirdId,
    this.status = HabitStatus.newHabit,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completionRateLast30Days = 0.0,
    this.activeDays = 0,
  });

  Habit copyWith({
    String? wirdId,
    HabitStatus? status,
    int? currentStreak,
    int? longestStreak,
    double? completionRateLast30Days,
    int? activeDays,
  }) {
    return Habit(
      wirdId: wirdId ?? this.wirdId,
      status: status ?? this.status,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completionRateLast30Days: completionRateLast30Days ?? this.completionRateLast30Days,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}
