import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/state/state_machine.dart';
import 'package:alfager/features/users/domain/models/user_status.dart';

void main() {
  group('WakeUpStateMachine Tests', () {
    test('Pending user transitions to calling on startCall', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.pending,
        event: WakeUpEvent.startCall,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.calling));
    });

    test('Calling user transitions to awake on callAnswered', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.calling,
        event: WakeUpEvent.callAnswered,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.awake));
    });

    test('Calling user transitions to needsRetry if retries < maxRetries', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.calling,
        event: WakeUpEvent.callNoAnswer,
        currentRetries: 1,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.needsRetry));
    });

    test('Calling user transitions to failed if retries >= maxRetries', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.calling,
        event: WakeUpEvent.callNoAnswer,
        currentRetries: 2,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.failed));
    });

    test('Awake user transitions to needsFollowUp on triggerFollowUp', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.awake,
        event: WakeUpEvent.triggerFollowUp,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.needsFollowUp));
    });

    test('needsFollowUp transitions to prayed on positive prayer answer', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.needsFollowUp,
        event: WakeUpEvent.prayerAnswerPositive,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.prayed));
    });

    test('needsFollowUp transitions to secondFollowUp on negative prayer answer', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.needsFollowUp,
        event: WakeUpEvent.prayerAnswerNegative,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.secondFollowUp));
    });

    test('secondFollowUp transitions to notPrayed on negative answer', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.secondFollowUp,
        event: WakeUpEvent.prayerAnswerNegative,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.notPrayed));
    });

    test('Opt-out request transitions to optedOut immediately', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.calling,
        event: WakeUpEvent.requestOptOut,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: false,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.optedOut));
    });

    test('Snooze allowed when currentSnoozes < maxSnoozes', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.awake,
        event: WakeUpEvent.requestSnooze,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 1,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isTrue);
      expect(res.newStatus, equals(UserStatus.snoozed));
    });

    test('Snooze fails when maxSnoozes reached', () {
      final res = WakeUpStateMachine.transition(
        currentStatus: UserStatus.awake,
        event: WakeUpEvent.requestSnooze,
        currentRetries: 0,
        maxRetries: 2,
        currentSnoozes: 2,
        maxSnoozes: 2,
        isOptedIn: true,
      );

      expect(res.isSuccess, isFalse);
      expect(res.newStatus, equals(UserStatus.awake));
    });
  });
}
