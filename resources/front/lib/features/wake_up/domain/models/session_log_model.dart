import '../../../users/domain/models/user_status.dart';

/// Timeline Event type during a Wake-up session.
enum SessionEventType {
  sessionStarted,
  callInitiated,
  callAnswered,
  callNoAnswer,
  callFailed,
  userAwake,
  followUpTriggered,
  prayerConfirmed,
  prayerNotDone,
  snoozed,
  optedOut,
  emergencyStopped,
  sessionFinished,
}

/// Represents a single chronological log event in the Fajr timeline.
class SessionLogModel {
  final String id;
  final DateTime timestamp;
  final String? userId;
  final String? userName;
  final SessionEventType eventType;
  final String message;
  final UserStatus? oldStatus;
  final UserStatus? newStatus;

  const SessionLogModel({
    required this.id,
    required this.timestamp,
    this.userId,
    this.userName,
    required this.eventType,
    required this.message,
    this.oldStatus,
    this.newStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'eventType': eventType.name,
      'message': message,
      'oldStatus': oldStatus?.name,
      'newStatus': newStatus?.name,
    };
  }

  factory SessionLogModel.fromJson(Map<String, dynamic> json) {
    return SessionLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      eventType: SessionEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => SessionEventType.sessionStarted,
      ),
      message: json['message'] as String,
      oldStatus: json['oldStatus'] != null
          ? UserStatus.values.firstWhere((s) => s.name == json['oldStatus'])
          : null,
      newStatus: json['newStatus'] != null
          ? UserStatus.values.firstWhere((s) => s.name == json['newStatus'])
          : null,
    );
  }
}
