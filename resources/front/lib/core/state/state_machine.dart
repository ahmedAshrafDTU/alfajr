import '../../features/users/domain/models/user_status.dart';

/// Events that drive the WakeUp State Machine transitions.
enum WakeUpEvent {
  startCall,
  callAnswered,
  callNoAnswer,
  callFailed,
  confirmAwake,
  triggerFollowUp,
  prayerAnswerPositive,
  prayerAnswerNegative,
  requestSnooze,
  requestOptOut,
  requestPause,
  triggerEmergencyStop,
  resetForNewSession,
}

/// Result of a state transition attempt.
class TransitionResult {
  final bool isSuccess;
  final UserStatus newStatus;
  final String? errorMessage;
  final String? eventDescription;

  const TransitionResult({
    required this.isSuccess,
    required this.newStatus,
    this.errorMessage,
    this.eventDescription,
  });

  factory TransitionResult.success(UserStatus status, [String? description]) {
    return TransitionResult(
      isSuccess: true,
      newStatus: status,
      eventDescription: description,
    );
  }

  factory TransitionResult.failure(UserStatus currentStatus, String reason) {
    return TransitionResult(
      isSuccess: false,
      newStatus: currentStatus,
      errorMessage: reason,
    );
  }
}

/// Strict, formal state machine governing user wake-up and prayer confirmation life-cycle.
class WakeUpStateMachine {
  /// Evaluates and transitions a user status given an event and context parameters.
  static TransitionResult transition({
    required UserStatus currentStatus,
    required WakeUpEvent event,
    required int currentRetries,
    required int maxRetries,
    required int currentSnoozes,
    required int maxSnoozes,
    required bool isOptedIn,
  }) {
    // 1. Opt-in safety check: Opted-out users cannot transition into calling/active states
    if (event == WakeUpEvent.requestOptOut) {
      return TransitionResult.success(
        UserStatus.optedOut,
        'المستخدم طلب إلغاء الاشتراك (Opt-out)',
      );
    }

    if (!isOptedIn || currentStatus == UserStatus.optedOut) {
      if (event == WakeUpEvent.startCall) {
        return TransitionResult.failure(
          currentStatus,
          'المستخدم ملغي اشتراكه أو لم يمنح الموافقة الصريحة ولا يجوز الاتصال به.',
        );
      }
    }

    // 2. Emergency stop or session reset
    if (event == WakeUpEvent.triggerEmergencyStop) {
      if (currentStatus == UserStatus.calling) {
        return TransitionResult.success(
          UserStatus.pending,
          'تم إيقاف المكالمة فوراً بواسطة الإيقاف الطارئ',
        );
      }
      return TransitionResult.success(currentStatus, 'إيقاف طارئ');
    }

    if (event == WakeUpEvent.resetForNewSession) {
      if (currentStatus == UserStatus.optedOut) {
        return TransitionResult.success(UserStatus.optedOut, 'مستمر بالإلغاء');
      }
      return TransitionResult.success(UserStatus.pending, 'إعادة تهيئة لجلسة فجر جديدة');
    }

    if (event == WakeUpEvent.requestPause) {
      return TransitionResult.success(UserStatus.paused, 'تم إيقاف المستخدم مؤقتاً');
    }

    // 3. State transition matrix
    switch (currentStatus) {
      case UserStatus.pending:
      case UserStatus.snoozed:
        if (event == WakeUpEvent.startCall) {
          return TransitionResult.success(UserStatus.calling, 'بدء الاتصال بالمستخدم');
        }
        break;

      case UserStatus.calling:
        if (event == WakeUpEvent.callAnswered) {
          return TransitionResult.success(UserStatus.awake, 'رد المستخدم وأصبح مستيقظاً');
        } else if (event == WakeUpEvent.prayerAnswerPositive) {
          return TransitionResult.success(UserStatus.prayed, 'أكد المستخدم أداء صلاة الفجر');
        } else if (event == WakeUpEvent.prayerAnswerNegative) {
          return TransitionResult.success(
            UserStatus.secondFollowUp,
            'أفاد المستخدم بأنه لم يصلِّ بعد، مجدول للمتابعة الأخيرة',
          );
        } else if (event == WakeUpEvent.requestSnooze) {
          if (currentSnoozes < maxSnoozes) {
            return TransitionResult.success(UserStatus.snoozed, 'تم تأجيل التنبيه');
          }
        } else if (event == WakeUpEvent.callNoAnswer || event == WakeUpEvent.callFailed) {
          if (currentRetries < maxRetries) {
            return TransitionResult.success(
              UserStatus.needsRetry,
              'لم يرد المستخدم، مجدول لإعادة المحاولة ($currentRetries / $maxRetries)',
            );
          } else {
            return TransitionResult.success(
              UserStatus.failed,
              'تجاوز الحد الأقصى للمحاولات ($maxRetries) دون إجابة',
            );
          }
        }
        break;

      case UserStatus.needsRetry:
        if (event == WakeUpEvent.startCall) {
          return TransitionResult.success(UserStatus.calling, 'إعادة الاتصال بالمستخدم');
        }
        break;

      case UserStatus.awake:
        if (event == WakeUpEvent.triggerFollowUp) {
          return TransitionResult.success(UserStatus.needsFollowUp, 'بدء مرحلة متابعة أداء الصلاة');
        } else if (event == WakeUpEvent.prayerAnswerPositive) {
          return TransitionResult.success(UserStatus.prayed, 'أكد المستخدم أنه صلى الفجر');
        } else if (event == WakeUpEvent.requestSnooze) {
          if (currentSnoozes < maxSnoozes) {
            return TransitionResult.success(
              UserStatus.snoozed,
              'طلب المستخدم غفوة (${currentSnoozes + 1} / $maxSnoozes)',
            );
          } else {
            return TransitionResult.failure(
              currentStatus,
              'تم استنفاد الحد الأقصى للغفوات المسموح بها ($maxSnoozes)',
            );
          }
        }
        break;

      case UserStatus.needsFollowUp:
        if (event == WakeUpEvent.startCall) {
          return TransitionResult.success(UserStatus.calling, 'بدء مكالمة متابعة الصلاة');
        } else if (event == WakeUpEvent.prayerAnswerPositive) {
          return TransitionResult.success(UserStatus.prayed, 'أكد المستخدم أداء صلاة الفجر');
        } else if (event == WakeUpEvent.prayerAnswerNegative) {
          return TransitionResult.success(
            UserStatus.secondFollowUp,
            'أفاد المستخدم بأنه لم يصلِّ بعد، مجدول للمتابعة الأخيرة',
          );
        } else if (event == WakeUpEvent.requestSnooze) {
          if (currentSnoozes < maxSnoozes) {
            return TransitionResult.success(UserStatus.snoozed, 'تم تأجيل المتابعة');
          }
        }
        break;

      case UserStatus.secondFollowUp:
        if (event == WakeUpEvent.startCall) {
          return TransitionResult.success(UserStatus.calling, 'بدء مكالمة المتابعة الأخيرة');
        } else if (event == WakeUpEvent.prayerAnswerPositive) {
          return TransitionResult.success(UserStatus.prayed, 'أكد المستخدم أداء الصلاة في المتابعة الأخيرة');
        } else if (event == WakeUpEvent.prayerAnswerNegative || event == WakeUpEvent.callNoAnswer) {
          return TransitionResult.success(
            UserStatus.notPrayed,
            'انتهت محاولات المتابعة وحالة المستخدم: لم يصلِّ بعد',
          );
        }
        break;

      case UserStatus.prayed:
        return TransitionResult.failure(currentStatus, 'المستخدم أكمل الصلاة بالفعل ولا حاجة لتغيير حالته.');

      case UserStatus.notPrayed:
      case UserStatus.failed:
      case UserStatus.optedOut:
      case UserStatus.paused:
        // Terminal states for the current session unless explicitly reset
        break;
    }

    return TransitionResult.failure(
      currentStatus,
      'انتقال غير صالح من الحالة [${currentStatus.name}] عبر الحدث [${event.name}]',
    );
  }
}
