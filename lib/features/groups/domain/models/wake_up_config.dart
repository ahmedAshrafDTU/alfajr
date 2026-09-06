import '../../../../core/constants/app_constants.dart';

/// Configuration for wake-up schedule, intervals, delays, and anti-spam rules.
class WakeUpConfig {
  final int retryDelayMinutes;
  final int maxRetries;
  final int prayerFollowUpDelayMinutes;
  final int secondFollowUpDelayMinutes;
  final int snoozeDurationMinutes;
  final int maxSnoozeCount;
  final List<int> daysEnabled; // 1 = Monday ... 7 = Sunday
  final String timezone;
  final bool enableSmartOrdering; // Prioritize high priority users first
  final int callTimeoutSeconds;

  const WakeUpConfig({
    this.retryDelayMinutes = AppConstants.defaultRetryDelayMinutes,
    this.maxRetries = AppConstants.defaultMaxRetries,
    this.prayerFollowUpDelayMinutes = AppConstants.defaultPrayerFollowUpMinutes,
    this.secondFollowUpDelayMinutes = AppConstants.defaultSecondFollowUpMinutes,
    this.snoozeDurationMinutes = AppConstants.defaultSnoozeMinutes,
    this.maxSnoozeCount = AppConstants.defaultMaxSnoozeCount,
    this.daysEnabled = const [1, 2, 3, 4, 5, 6, 7],
    this.timezone = 'Asia/Riyadh',
    this.enableSmartOrdering = true,
    this.callTimeoutSeconds = AppConstants.callTimeoutSeconds,
  });

  WakeUpConfig copyWith({
    int? retryDelayMinutes,
    int? maxRetries,
    int? prayerFollowUpDelayMinutes,
    int? secondFollowUpDelayMinutes,
    int? snoozeDurationMinutes,
    int? maxSnoozeCount,
    List<int>? daysEnabled,
    String? timezone,
    bool? enableSmartOrdering,
    int? callTimeoutSeconds,
  }) {
    return WakeUpConfig(
      retryDelayMinutes: retryDelayMinutes ?? this.retryDelayMinutes,
      maxRetries: maxRetries ?? this.maxRetries,
      prayerFollowUpDelayMinutes:
          prayerFollowUpDelayMinutes ?? this.prayerFollowUpDelayMinutes,
      secondFollowUpDelayMinutes:
          secondFollowUpDelayMinutes ?? this.secondFollowUpDelayMinutes,
      snoozeDurationMinutes:
          snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      daysEnabled: daysEnabled ?? this.daysEnabled,
      timezone: timezone ?? this.timezone,
      enableSmartOrdering: enableSmartOrdering ?? this.enableSmartOrdering,
      callTimeoutSeconds: callTimeoutSeconds ?? this.callTimeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retryDelayMinutes': retryDelayMinutes,
      'maxRetries': maxRetries,
      'prayerFollowUpDelayMinutes': prayerFollowUpDelayMinutes,
      'secondFollowUpDelayMinutes': secondFollowUpDelayMinutes,
      'snoozeDurationMinutes': snoozeDurationMinutes,
      'maxSnoozeCount': maxSnoozeCount,
      'daysEnabled': daysEnabled,
      'timezone': timezone,
      'enableSmartOrdering': enableSmartOrdering,
      'callTimeoutSeconds': callTimeoutSeconds,
    };
  }

  factory WakeUpConfig.fromJson(Map<String, dynamic> json) {
    return WakeUpConfig(
      retryDelayMinutes: json['retryDelayMinutes'] as int? ?? AppConstants.defaultRetryDelayMinutes,
      maxRetries: json['maxRetries'] as int? ?? AppConstants.defaultMaxRetries,
      prayerFollowUpDelayMinutes: json['prayerFollowUpDelayMinutes'] as int? ?? AppConstants.defaultPrayerFollowUpMinutes,
      secondFollowUpDelayMinutes: json['secondFollowUpDelayMinutes'] as int? ?? AppConstants.defaultSecondFollowUpMinutes,
      snoozeDurationMinutes: json['snoozeDurationMinutes'] as int? ?? AppConstants.defaultSnoozeMinutes,
      maxSnoozeCount: json['maxSnoozeCount'] as int? ?? AppConstants.defaultMaxSnoozeCount,
      daysEnabled: (json['daysEnabled'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [1, 2, 3, 4, 5, 6, 7],
      timezone: json['timezone'] as String? ?? 'Asia/Riyadh',
      enableSmartOrdering: json['enableSmartOrdering'] as bool? ?? true,
      callTimeoutSeconds: json['callTimeoutSeconds'] as int? ?? AppConstants.callTimeoutSeconds,
    );
  }
}
