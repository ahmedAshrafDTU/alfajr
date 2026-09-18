import '../../domain/models/analytics_model.dart';
import '../../domain/models/daily_session_history.dart';
import '../../../users/domain/models/user_status.dart';

abstract class HistoryRepository {
  Future<List<DailySessionHistory>> getHistory();
  Future<void> saveSession(DailySessionHistory session);
  Future<AnalyticsModel> getAnalytics();
}

class InMemoryHistoryRepository implements HistoryRepository {
  final List<DailySessionHistory> _history = [
    DailySessionHistory(
      id: 'sess_1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      fajrTime: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      sessionStartTime: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 15)),
      sessionEndTime: DateTime.now().subtract(const Duration(days: 1, hours: 7, minutes: 30)),
      totalParticipants: 6,
      awakeCount: 5,
      prayedCount: 5,
      failedCount: 1,
      participantRecords: [
        UserSessionRecord(
          userId: 'usr_1',
          userName: 'أحمد محمود',
          phone: '+966501112233',
          firstCallTime: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 10)),
          answeredTime: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 9)),
          prayerConfirmedTime: DateTime.now().subtract(const Duration(days: 1, hours: 7, minutes: 50)),
          finalStatus: UserStatus.prayed,
        ),
        UserSessionRecord(
          userId: 'usr_2',
          userName: 'محمد عبدالله',
          phone: '+966502223344',
          firstCallTime: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 8)),
          answeredTime: DateTime.now().subtract(const Duration(days: 1, hours: 8, minutes: 7)),
          prayerConfirmedTime: DateTime.now().subtract(const Duration(days: 1, hours: 7, minutes: 45)),
          finalStatus: UserStatus.prayed,
        ),
      ],
    ),
    DailySessionHistory(
      id: 'sess_2',
      date: DateTime.now().subtract(const Duration(days: 2)),
      fajrTime: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      sessionStartTime: DateTime.now().subtract(const Duration(days: 2, hours: 8, minutes: 15)),
      sessionEndTime: DateTime.now().subtract(const Duration(days: 2, hours: 7, minutes: 20)),
      totalParticipants: 6,
      awakeCount: 6,
      prayedCount: 4,
      failedCount: 0,
    ),
    DailySessionHistory(
      id: 'sess_3',
      date: DateTime.now().subtract(const Duration(days: 3)),
      fajrTime: DateTime.now().subtract(const Duration(days: 3, hours: 8)),
      sessionStartTime: DateTime.now().subtract(const Duration(days: 3, hours: 8, minutes: 15)),
      sessionEndTime: DateTime.now().subtract(const Duration(days: 3, hours: 7, minutes: 25)),
      totalParticipants: 6,
      awakeCount: 5,
      prayedCount: 4,
      failedCount: 1,
    ),
  ];

  @override
  Future<List<DailySessionHistory>> getHistory() async {
    return List.from(_history);
  }

  @override
  Future<void> saveSession(DailySessionHistory session) async {
    _history.insert(0, session);
  }

  @override
  Future<AnalyticsModel> getAnalytics() async {
    if (_history.isEmpty) {
      return const AnalyticsModel(
        overallWakeUpRate: 0,
        overallPrayerConfirmationRate: 0,
        averageRetriesPerUser: 0,
        totalSessionsConducted: 0,
        totalCallsDelivered: 0,
      );
    }

    int totalParticipantsSum = 0;
    int totalAwakeSum = 0;
    int totalPrayedSum = 0;

    for (final s in _history) {
      totalParticipantsSum += s.totalParticipants;
      totalAwakeSum += s.awakeCount;
      totalPrayedSum += s.prayedCount;
    }

    final wakeRate = totalParticipantsSum > 0 ? (totalAwakeSum / totalParticipantsSum) * 100 : 0.0;
    final prayerRate = totalParticipantsSum > 0 ? (totalPrayedSum / totalParticipantsSum) * 100 : 0.0;

    return AnalyticsModel(
      overallWakeUpRate: wakeRate,
      overallPrayerConfirmationRate: prayerRate,
      averageRetriesPerUser: 0.8,
      totalSessionsConducted: _history.length,
      totalCallsDelivered: totalParticipantsSum * 2,
      topConsistentUsers: const [
        UserMetric(userId: 'usr_1', userName: 'أحمد محمود', metricCount: 28, percentage: 96.5),
        UserMetric(userId: 'usr_2', userName: 'محمد عبدالله', metricCount: 27, percentage: 93.1),
      ],
      frequentNeedsFollowUpUsers: const [
        UserMetric(userId: 'usr_5', userName: 'خالد بن الوليد', metricCount: 12, percentage: 41.3),
      ],
      frequentNoAnswerUsers: const [
        UserMetric(userId: 'usr_6', userName: 'سلمان الفارس', metricCount: 5, percentage: 17.2),
      ],
      weeklyTrends: const [
        DailyRateTrend(dayName: 'السبت', wakeUpRate: 90, prayerRate: 85),
        DailyRateTrend(dayName: 'الأحد', wakeUpRate: 95, prayerRate: 90),
        DailyRateTrend(dayName: 'الإثنين', wakeUpRate: 88, prayerRate: 82),
        DailyRateTrend(dayName: 'الثلاثاء', wakeUpRate: 92, prayerRate: 88),
        DailyRateTrend(dayName: 'الأربعاء', wakeUpRate: 85, prayerRate: 80),
        DailyRateTrend(dayName: 'الخميس', wakeUpRate: 94, prayerRate: 91),
        DailyRateTrend(dayName: 'الجمعة', wakeUpRate: 100, prayerRate: 98),
      ],
    );
  }
}
