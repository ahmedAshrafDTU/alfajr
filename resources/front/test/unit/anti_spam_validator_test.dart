import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/utils/anti_spam_validator.dart';
import 'package:alfager/features/users/domain/models/user_model.dart';
import 'package:alfager/features/users/domain/models/user_status.dart';

void main() {
  group('AntiSpamValidator Tests', () {
    final now = DateTime(2026, 9, 3, 4, 30);
    final fajrTime = DateTime(2026, 9, 3, 4, 25);

    test('Valid opt-in user within fajr window is allowed to receive call', () {
      const user = UserModel(
        id: 'usr_valid',
        name: 'أحمد',
        phone: '+966501112233',
        isOptedIn: true,
        isEnabled: true,
        isWakeUpEnabled: true,
      );

      final result = AntiSpamValidator.canMakeCall(
        user: user,
        now: now,
        fajrTime: fajrTime,
      );

      expect(result.isAllowed, isTrue);
    });

    test('Opted out user is blocked from calls', () {
      const user = UserModel(
        id: 'usr_optout',
        name: 'محمد',
        phone: '+966502223344',
        isOptedIn: false,
        status: UserStatus.optedOut,
      );

      final result = AntiSpamValidator.canMakeCall(
        user: user,
        now: now,
        fajrTime: fajrTime,
      );

      expect(result.isAllowed, isFalse);
      expect(result.rejectionReason, contains('الموافقة المسبقة'));
    });

    test('User with max calls reached is blocked', () {
      final user = UserModel(
        id: 'usr_max',
        name: 'علي',
        phone: '+966503334455',
        isOptedIn: true,
        totalCallsMadeToday: 5,
        lastCalledAt: now.subtract(const Duration(minutes: 5)),
      );

      final result = AntiSpamValidator.canMakeCall(
        user: user,
        now: now,
        fajrTime: fajrTime,
        maxAllowedCalls: 5,
      );

      expect(result.isAllowed, isFalse);
      expect(result.rejectionReason, contains('المسموح بها'));
    });

    test('Cooldown interval is strictly enforced', () {
      final user = UserModel(
        id: 'usr_cooldown',
        name: 'عمر',
        phone: '+966504445566',
        isOptedIn: true,
        totalCallsMadeToday: 1,
        lastCalledAt: now.subtract(const Duration(seconds: 30)), // only 30s ago
      );

      final result = AntiSpamValidator.canMakeCall(
        user: user,
        now: now,
        fajrTime: fajrTime,
        minIntervalSeconds: 120,
      );

      expect(result.isAllowed, isFalse);
      expect(result.rejectionReason, contains('فترة الانتظار الإلزامية'));
    });

    test('Calls outside Fajr window are rejected', () {
      const user = UserModel(
        id: 'usr_window',
        name: 'خالد',
        phone: '+966505556677',
        isOptedIn: true,
      );

      final farTime = DateTime(2026, 9, 3, 14, 0); // 2:00 PM (way outside Fajr)

      final result = AntiSpamValidator.canMakeCall(
        user: user,
        now: farTime,
        fajrTime: fajrTime,
        fajrWindowMinutes: 90,
      );

      expect(result.isAllowed, isFalse);
      expect(result.rejectionReason, contains('خارج نافذة صلاة الفجر'));
    });
  });
}
