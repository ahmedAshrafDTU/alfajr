/// Aggregated statistics and analytics metrics for the Al-Fajr system.
class AnalyticsModel {
  final double overallWakeUpRate;
  final double overallPrayerConfirmationRate;
  final double averageRetriesPerUser;
  final int totalSessionsConducted;
  final int totalCallsDelivered;
  final List<UserMetric> topConsistentUsers;
  final List<UserMetric> frequentNeedsFollowUpUsers;
  final List<UserMetric> frequentNoAnswerUsers;
  final List<DailyRateTrend> weeklyTrends;

  const AnalyticsModel({
    required this.overallWakeUpRate,
    required this.overallPrayerConfirmationRate,
    required this.averageRetriesPerUser,
    required this.totalSessionsConducted,
    required this.totalCallsDelivered,
    this.topConsistentUsers = const [],
    this.frequentNeedsFollowUpUsers = const [],
    this.frequentNoAnswerUsers = const [],
    this.weeklyTrends = const [],
  });
}

class UserMetric {
  final String userId;
  final String userName;
  final int metricCount;
  final double percentage;

  const UserMetric({
    required this.userId,
    required this.userName,
    required this.metricCount,
    required this.percentage,
  });
}

class DailyRateTrend {
  final String dayName;
  final double wakeUpRate;
  final double prayerRate;

  const DailyRateTrend({
    required this.dayName,
    required this.wakeUpRate,
    required this.prayerRate,
  });
}
