import '../../../../core/storage/local_storage_service.dart';
import '../../domain/models/analytics_model.dart';
import '../../domain/models/daily_session_history.dart';
import '../../../users/domain/models/user_status.dart';
import 'history_repository.dart';

/// Persistent History Repository using durable local storage.
class PersistentHistoryRepository implements HistoryRepository {
  static const String _storageKey = 'alfager_history';
  final LocalStorageService storageService;
  final List<DailySessionHistory> _cachedHistory = [];
  bool _isLoaded = false;

  PersistentHistoryRepository({required this.storageService});

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    final jsonList = await storageService.readJsonList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _cachedHistory.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            _cachedHistory.add(DailySessionHistory.fromJson(item));
          } catch (_) {}
        }
      }
    } else {
      _cachedHistory.addAll(_defaultSeedHistory);
      await _persist();
    }
    _isLoaded = true;
  }

  Future<void> _persist() async {
    final list = _cachedHistory.map((h) => h.toJson()).toList();
    await storageService.writeJsonList(_storageKey, list);
  }

  @override
  Future<List<DailySessionHistory>> getHistory() async {
    await _ensureLoaded();
    return List.unmodifiable(_cachedHistory);
  }

  @override
  Future<void> saveSession(DailySessionHistory session) async {
    await _ensureLoaded();
    final index = _cachedHistory.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _cachedHistory[index] = session;
    } else {
      _cachedHistory.insert(0, session);
    }
    await _persist();
  }

  Future<void> clearHistory() async {
    await _ensureLoaded();
    _cachedHistory.clear();
    await _persist();
  }

  @override
  Future<AnalyticsModel> getAnalytics() async {
    await _ensureLoaded();
    if (_cachedHistory.isEmpty) {
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

    for (final session in _cachedHistory) {
      totalParticipantsSum += session.totalParticipants;
      totalAwakeSum += session.awakeCount;
      totalPrayedSum += session.prayedCount;
    }

    final wakeUpRate = totalParticipantsSum > 0
        ? (totalAwakeSum / totalParticipantsSum) * 100
        : 0.0;
    final prayerRate = totalParticipantsSum > 0
        ? (totalPrayedSum / totalParticipantsSum) * 100
        : 0.0;

    return AnalyticsModel(
      overallWakeUpRate: wakeUpRate,
      overallPrayerConfirmationRate: prayerRate,
      averageRetriesPerUser: 0.8,
      totalSessionsConducted: _cachedHistory.length,
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

  static final List<DailySessionHistory> _defaultSeedHistory = [
    DailySessionHistory(
      id: 'sess_yesterday',
      date: DateTime.now().subtract(const Duration(days: 1)),
      fajrTime: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      sessionStartTime: DateTime.now().subtract(const Duration(days: 1, hours: 10, minutes: 5)),
      sessionEndTime: DateTime.now().subtract(const Duration(days: 1, hours: 9, minutes: 30)),
      totalParticipants: 6,
      awakeCount: 5,
      prayedCount: 5,
      failedCount: 1,
      participantRecords: [
        UserSessionRecord(
          userId: 'usr_1',
          userName: 'أحمد محمود',
          phone: '+966501112233',
          finalStatus: UserStatus.prayed,
          retries: 0,
          answeredTime: DateTime.now().subtract(const Duration(days: 1, hours: 10, minutes: 2)),
          prayerConfirmedTime: DateTime.now().subtract(const Duration(days: 1, hours: 9, minutes: 50)),
        ),
        UserSessionRecord(
          userId: 'usr_2',
          userName: 'محمد عبدالله',
          phone: '+966502223344',
          finalStatus: UserStatus.prayed,
          retries: 1,
          answeredTime: DateTime.now().subtract(const Duration(days: 1, hours: 9, minutes: 55)),
          prayerConfirmedTime: DateTime.now().subtract(const Duration(days: 1, hours: 9, minutes: 40)),
        ),
      ],
    ),
  ];
}
