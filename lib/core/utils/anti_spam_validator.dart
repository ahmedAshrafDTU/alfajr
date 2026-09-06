import '../constants/app_constants.dart';
import '../../features/users/domain/models/user_model.dart';
import '../../features/users/domain/models/user_status.dart';

/// Validation result from anti-spam rules engine.
class AntiSpamResult {
  final bool isAllowed;
  final String? rejectionReason;

  const AntiSpamResult({required this.isAllowed, this.rejectionReason});

  factory AntiSpamResult.allowed() => const AntiSpamResult(isAllowed: true);
  factory AntiSpamResult.blocked(String reason) =>
      AntiSpamResult(isAllowed: false, rejectionReason: reason);
}

/// Enforces strict Anti-Spam and privacy constraints before any call can be made.
class AntiSpamValidator {
  /// Validates whether a user can be called right now.
  static AntiSpamResult canMakeCall({
    required UserModel user,
    required DateTime now,
    required DateTime fajrTime,
    int maxAllowedCalls = AppConstants.maxAllowedCallsPerUserPerSession,
    int minIntervalSeconds = AppConstants.minIntervalSecondsBetweenCalls,
    int fajrWindowMinutes = AppConstants.sessionFajrWindowMinutes,
  }) {
    // 1. Consent & Opt-in validation
    if (!user.isOptedIn || user.status == UserStatus.optedOut) {
      return AntiSpamResult.blocked(
        'المستخدم لم يمنح الموافقة المسبقة أو قام بإلغاء الاشتراك (Opted-Out).',
      );
    }

    // 2. User enabled & wake-up enabled check
    if (!user.isEnabled || !user.isWakeUpEnabled) {
      return AntiSpamResult.blocked('تم تعطيل استقبال التنبيهات من قبل المستخدم.');
    }

    // 3. User paused check (e.g. pause today or vacation mode)
    if (user.isPausedToday || user.isVacationMode) {
      return AntiSpamResult.blocked('المستخدم في وضع الإجازة أو الإيقاف المؤقت لليوم.');
    }

    // 4. Terminal status check
    if (user.status == UserStatus.prayed) {
      return AntiSpamResult.blocked('المستخدم أدى الصلاة بالفعل، يمنع الاتصال به مجدداً.');
    }

    // 5. Total call count check (anti-harassment)
    if (user.totalCallsMadeToday >= maxAllowedCalls) {
      return AntiSpamResult.blocked(
        'تم الوصول للحد الأقصى للاتصالات المسموح بها ($maxAllowedCalls) خلال جلسة اليوم.',
      );
    }

    // 6. Minimum interval / Cooldown period check
    if (user.lastCalledAt != null) {
      final elapsedSeconds = now.difference(user.lastCalledAt!).inSeconds;
      if (elapsedSeconds < minIntervalSeconds) {
        final remainingSec = minIntervalSeconds - elapsedSeconds;
        return AntiSpamResult.blocked(
          'فترة الانتظار الإلزامية نشطة. يرجى الانتظار $remainingSec ثانية قبل الاتصال التالي.',
        );
      }
    }

    // 7. Fajr time window check (Prevent calls in the middle of the day/night)
    final diffFromFajr = now.difference(fajrTime).inMinutes.abs();
    if (diffFromFajr > fajrWindowMinutes) {
      return AntiSpamResult.blocked(
        'الوقت الحالي خارج نافذة صلاة الفجر المسموح بها (± $fajrWindowMinutes دقيقة).',
      );
    }

    return AntiSpamResult.allowed();
  }
}
