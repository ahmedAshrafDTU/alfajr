import 'user_status.dart';

/// Participant / User Model in Al-Fajr application.
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String timezone;
  final String language;
  final bool isEnabled;
  final bool isWakeUpEnabled;
  final bool isFollowUpEnabled;
  final int priority; // 1 = High, 2 = Normal, 3 = Low
  final int retryCount;
  final int snoozeCount;
  final int totalCallsMadeToday;
  final DateTime? lastCalledAt;
  final DateTime? answeredAt;
  final DateTime? prayedAt;
  final UserStatus status;
  final bool isOptedIn; // Explicit consent
  final DateTime? optedInAt;
  final DateTime? optedOutAt;
  final bool isPausedToday;
  final bool isVacationMode;
  final String? groupId;
  final String? notes;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.timezone = 'Asia/Riyadh',
    this.language = 'ar',
    this.isEnabled = true,
    this.isWakeUpEnabled = true,
    this.isFollowUpEnabled = true,
    this.priority = 2,
    this.retryCount = 0,
    this.snoozeCount = 0,
    this.totalCallsMadeToday = 0,
    this.lastCalledAt,
    this.answeredAt,
    this.prayedAt,
    this.status = UserStatus.pending,
    this.isOptedIn = true,
    this.optedInAt,
    this.optedOutAt,
    this.isPausedToday = false,
    this.isVacationMode = false,
    this.groupId,
    this.notes,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? timezone,
    String? language,
    bool? isEnabled,
    bool? isWakeUpEnabled,
    bool? isFollowUpEnabled,
    int? priority,
    int? retryCount,
    int? snoozeCount,
    int? totalCallsMadeToday,
    DateTime? lastCalledAt,
    DateTime? answeredAt,
    DateTime? prayedAt,
    UserStatus? status,
    bool? isOptedIn,
    DateTime? optedInAt,
    DateTime? optedOutAt,
    bool? isPausedToday,
    bool? isVacationMode,
    String? groupId,
    String? notes,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      isEnabled: isEnabled ?? this.isEnabled,
      isWakeUpEnabled: isWakeUpEnabled ?? this.isWakeUpEnabled,
      isFollowUpEnabled: isFollowUpEnabled ?? this.isFollowUpEnabled,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      totalCallsMadeToday: totalCallsMadeToday ?? this.totalCallsMadeToday,
      lastCalledAt: lastCalledAt ?? this.lastCalledAt,
      answeredAt: answeredAt ?? this.answeredAt,
      prayedAt: prayedAt ?? this.prayedAt,
      status: status ?? this.status,
      isOptedIn: isOptedIn ?? this.isOptedIn,
      optedInAt: optedInAt ?? this.optedInAt,
      optedOutAt: optedOutAt ?? this.optedOutAt,
      isPausedToday: isPausedToday ?? this.isPausedToday,
      isVacationMode: isVacationMode ?? this.isVacationMode,
      groupId: groupId ?? this.groupId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'timezone': timezone,
      'language': language,
      'isEnabled': isEnabled,
      'isWakeUpEnabled': isWakeUpEnabled,
      'isFollowUpEnabled': isFollowUpEnabled,
      'priority': priority,
      'retryCount': retryCount,
      'snoozeCount': snoozeCount,
      'totalCallsMadeToday': totalCallsMadeToday,
      'lastCalledAt': lastCalledAt?.toIso8601String(),
      'answeredAt': answeredAt?.toIso8601String(),
      'prayedAt': prayedAt?.toIso8601String(),
      'status': status.name,
      'isOptedIn': isOptedIn,
      'optedInAt': optedInAt?.toIso8601String(),
      'optedOutAt': optedOutAt?.toIso8601String(),
      'isPausedToday': isPausedToday,
      'isVacationMode': isVacationMode,
      'groupId': groupId,
      'notes': notes,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      timezone: json['timezone'] as String? ?? 'Asia/Riyadh',
      language: json['language'] as String? ?? 'ar',
      isEnabled: json['isEnabled'] as bool? ?? true,
      isWakeUpEnabled: json['isWakeUpEnabled'] as bool? ?? true,
      isFollowUpEnabled: json['isFollowUpEnabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 2,
      retryCount: json['retryCount'] as int? ?? 0,
      snoozeCount: json['snoozeCount'] as int? ?? 0,
      totalCallsMadeToday: json['totalCallsMadeToday'] as int? ?? 0,
      lastCalledAt: json['lastCalledAt'] != null
          ? DateTime.parse(json['lastCalledAt'] as String)
          : null,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
      prayedAt: json['prayedAt'] != null
          ? DateTime.parse(json['prayedAt'] as String)
          : null,
      status: UserStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => UserStatus.pending,
      ),
      isOptedIn: json['isOptedIn'] as bool? ?? true,
      optedInAt: json['optedInAt'] != null
          ? DateTime.parse(json['optedInAt'] as String)
          : null,
      optedOutAt: json['optedOutAt'] != null
          ? DateTime.parse(json['optedOutAt'] as String)
          : null,
      isPausedToday: json['isPausedToday'] as bool? ?? false,
      isVacationMode: json['isVacationMode'] as bool? ?? false,
      groupId: json['groupId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
