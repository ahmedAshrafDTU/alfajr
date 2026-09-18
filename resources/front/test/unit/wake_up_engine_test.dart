import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/features/groups/domain/models/wake_up_config.dart';
import 'package:alfager/features/users/domain/models/user_model.dart';
import 'package:alfager/features/users/domain/models/user_status.dart';
import 'package:alfager/features/wake_up/domain/services/mock_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/wake_up_engine.dart';

void main() {
  group('WakeUpEngine Lifecycle Tests', () {
    test('Runs full session and moves answering users to prayed state', () async {
      final mockCallService = MockCallService(
        defaultBehavior: MockCallBehavior.alwaysAnswerAndPrayed,
        simulatedRingingDelay: const Duration(milliseconds: 10),
      );

      final engine = WakeUpEngine(
        callService: mockCallService,
        config: const WakeUpConfig(
          maxRetries: 2,
          retryDelayMinutes: 1,
          prayerFollowUpDelayMinutes: 1,
        ),
      );

      final users = [
        const UserModel(id: 'u1', name: 'أحمد', phone: '+966501111111', isOptedIn: true),
        const UserModel(id: 'u2', name: 'محمد', phone: '+966502222222', isOptedIn: true),
      ];

      engine.setUsers(users);

      await engine.runFullSession(simulationSpeed: true);

      expect(engine.sessionStatus, equals(EngineSessionStatus.completed));
      expect(engine.users.every((u) => u.status == UserStatus.prayed), isTrue);
      expect(engine.logs.isNotEmpty, isTrue);

      engine.dispose();
    });

    test('Handles no-answer users and retries up to maxRetries', () async {
      final mockCallService = MockCallService(
        defaultBehavior: MockCallBehavior.alwaysNoAnswer,
        simulatedRingingDelay: const Duration(milliseconds: 10),
      );

      final engine = WakeUpEngine(
        callService: mockCallService,
        config: const WakeUpConfig(
          maxRetries: 2,
        ),
      );

      final users = [
        const UserModel(id: 'u1', name: 'خالد', phone: '+966503333333', isOptedIn: true),
      ];

      engine.setUsers(users);

      await engine.runFullSession(simulationSpeed: true);

      expect(engine.users.first.status, equals(UserStatus.failed));
      expect(engine.users.first.retryCount, equals(2));

      engine.dispose();
    });

    test('Emergency stop immediately halts session and resets calling status', () async {
      final mockCallService = MockCallService(
        defaultBehavior: MockCallBehavior.alwaysAnswerAndPrayed,
        simulatedRingingDelay: const Duration(seconds: 2),
      );

      final engine = WakeUpEngine(
        callService: mockCallService,
      );

      final users = [
        const UserModel(id: 'u1', name: 'طارق', phone: '+966504444444', isOptedIn: true),
      ];

      engine.setUsers(users);

      // Trigger run and immediate emergency stop
      unawaited(engine.runFullSession());
      await Future.delayed(const Duration(milliseconds: 50));
      engine.emergencyStop();

      expect(engine.isRunning, isFalse);
      expect(engine.sessionStatus, equals(EngineSessionStatus.emergencyStopped));

      engine.dispose();
    });
  });
}
