import '../../../users/domain/models/user_status.dart';
import '../../../wake_up/domain/models/session_log_model.dart';

/// Historical record of an individual participant in a daily Fajr session.
class UserSessionRecord {
  final String userId;
  final String userName;
  final String phone;
  final DateTime? firstCallTime;
  final DateTime? answeredTime;
  final DateTime? prayerConfirmedTime;
  final int retries;
  final int snoozes;
  final UserStatus finalStatus;

  const UserSessionRecord({
    required this.userId,
    required this.userName,
    required this.phone,
    this.firstCallTime,
    this.answeredTime,
    this.prayerConfirmedTime,
    this.retries = 0,
    this.snoozes = 0,
    required this.finalStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'phone': phone,
      'firstCallTime': firstCallTime?.toIso8601String(),
      'answeredTime': answeredTime?.toIso8601String(),
      'prayerConfirmedTime': prayerConfirmedTime?.toIso8601String(),
      'retries': retries,
      'snoozes': snoozes,
      'finalStatus': finalStatus.name,
    };
  }

  factory UserSessionRecord.fromJson(Map<String, dynamic> json) {
    return UserSessionRecord(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      phone: json['phone'] as String,
      firstCallTime: json['firstCallTime'] != null
          ? DateTime.parse(json['firstCallTime'] as String)
          : null,
      answeredTime: json['answeredTime'] != null
          ? DateTime.parse(json['answeredTime'] as String)
          : null,
      prayerConfirmedTime: json['prayerConfirmedTime'] != null
          ? DateTime.parse(json['prayerConfirmedTime'] as String)
          : null,
      retries: json['retries'] as int? ?? 0,
      snoozes: json['snoozes'] as int? ?? 0,
      finalStatus: UserStatus.values.firstWhere(
        (s) => s.name == json['finalStatus'],
        orElse: () => UserStatus.pending,
      ),
    );
  }
}

/// Historical record of a full daily Fajr session.
class DailySessionHistory {
  final String id;
  final DateTime date;
  final DateTime fajrTime;
  final DateTime sessionStartTime;
  final DateTime? sessionEndTime;
  final int totalParticipants;
  final int awakeCount;
  final int prayedCount;
  final int failedCount;
  final List<UserSessionRecord> participantRecords;
  final List<SessionLogModel> logs;

  const DailySessionHistory({
    required this.id,
    required this.date,
    required this.fajrTime,
    required this.sessionStartTime,
    this.sessionEndTime,
    required this.totalParticipants,
    required this.awakeCount,
    required this.prayedCount,
    required this.failedCount,
    this.participantRecords = const [],
    this.logs = const [],
  });

  double get wakeUpSuccessRate =>
      totalParticipants > 0 ? (awakeCount / totalParticipants) * 100 : 0.0;

  double get prayerConfirmationRate =>
      totalParticipants > 0 ? (prayedCount / totalParticipants) * 100 : 0.0;

  int get totalCallsMade =>
      participantRecords.fold(0, (sum, r) => sum + 1 + r.retries);

  int get totalAwoke => awakeCount;
  int get totalPrayed => prayedCount;
  int get totalFailed => failedCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'fajrTime': fajrTime.toIso8601String(),
      'sessionStartTime': sessionStartTime.toIso8601String(),
      'sessionEndTime': sessionEndTime?.toIso8601String(),
      'totalParticipants': totalParticipants,
      'awakeCount': awakeCount,
      'prayedCount': prayedCount,
      'failedCount': failedCount,
      'participantRecords': participantRecords.map((e) => e.toJson()).toList(),
      'logs': logs.map((e) => e.toJson()).toList(),
    };
  }

  factory DailySessionHistory.fromJson(Map<String, dynamic> json) {
    return DailySessionHistory(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      fajrTime: DateTime.parse(json['fajrTime'] as String),
      sessionStartTime: DateTime.parse(json['sessionStartTime'] as String),
      sessionEndTime: json['sessionEndTime'] != null
          ? DateTime.parse(json['sessionEndTime'] as String)
          : null,
      totalParticipants: json['totalParticipants'] as int,
      awakeCount: json['awakeCount'] as int,
      prayedCount: json['prayedCount'] as int,
      failedCount: json['failedCount'] as int,
      participantRecords: (json['participantRecords'] as List<dynamic>?)
              ?.map((e) => UserSessionRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => SessionLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
