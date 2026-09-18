import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/audio/audio_prompts.dart';
import 'package:alfager/core/state/state_machine.dart';
import 'package:alfager/core/storage/local_storage_service.dart';
import 'package:alfager/core/utils/permission_manager.dart';
import 'package:alfager/features/groups/data/repositories/persistent_group_repository.dart';
import 'package:alfager/features/groups/domain/models/group_model.dart';
import 'package:alfager/features/history_analytics/data/repositories/persistent_history_repository.dart';
import 'package:alfager/features/history_analytics/domain/models/daily_session_history.dart';
import 'package:alfager/features/settings/data/repositories/persistent_settings_repository.dart';
import 'package:alfager/features/users/data/repositories/persistent_user_repository.dart';
import 'package:alfager/features/users/domain/models/user_model.dart';
import 'package:alfager/features/users/domain/models/user_status.dart';
import 'package:alfager/features/wake_up/domain/services/backend_proxy_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/call_service.dart';
import 'package:alfager/features/wake_up/domain/services/mock_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/twilio_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/wake_up_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Full Wake-Up Journey Integration Tests', () {
    late LocalStorageService storage;
    late PersistentUserRepository userRepo;
    late PersistentGroupRepository groupRepo;
    late PersistentHistoryRepository historyRepo;
    late PersistentSettingsRepository settingsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = SharedPrefsLocalStorageService();
      await storage.init();
      userRepo = PersistentUserRepository(storageService: storage);
      groupRepo = PersistentGroupRepository(storageService: storage);
      historyRepo = PersistentHistoryRepository(storageService: storage);
      settingsRepo = PersistentSettingsRepository(storageService: storage);
    });

    tearDown(() async {
      await storage.clear();
    });

    test('End-to-End: Repositories persist, update, delete, and reload data across fresh instances', () async {
      final initialUsers = await userRepo.getUsers();
      expect(initialUsers.isNotEmpty, isTrue);

      final initialGroups = await groupRepo.getGroups();
      expect(initialGroups.isNotEmpty, isTrue);

      final initialHistory = await historyRepo.getHistory();
      expect(initialHistory.isNotEmpty, isTrue);

      final settings = await settingsRepo.getSettings();
      expect(settings.strictAntiSpamEnabled, isTrue);

      // Save user
      const testUser = UserModel(
        id: 'int_user_1',
        name: 'سعد الدين',
        phone: '+966551234567',
        isOptedIn: true,
      );
      await userRepo.saveUser(testUser);

      // Save group
      final newGroup = GroupModel(
        id: 'grp_new',
        name: 'مجموعة الفجر',
        createdAt: DateTime.now(),
      );
      await groupRepo.saveGroup(newGroup);

      // Save session
      final session = DailySessionHistory(
        id: 'sess_test_1',
        date: DateTime.now(),
        fajrTime: DateTime.now(),
        sessionStartTime: DateTime.now(),
        totalParticipants: 2,
        awakeCount: 2,
        prayedCount: 2,
        failedCount: 0,
      );
      await historyRepo.saveSession(session);

      // Verify re-instantiated repositories read identical persisted data
      final newRepo = PersistentUserRepository(storageService: storage);
      final loaded = await newRepo.getUserById('int_user_1');
      expect(loaded, isNotNull);
      expect(loaded?.name, equals('سعد الدين'));

      // Update user
      await newRepo.updateUserStatus('int_user_1', UserStatus.awake);
      final updated = await newRepo.getUserById('int_user_1');
      expect(updated?.status, equals(UserStatus.awake));

      // Delete user
      await newRepo.deleteUser('int_user_1');
      final deleted = await newRepo.getUserById('int_user_1');
      expect(deleted, isNull);

      final newGroupRepo = PersistentGroupRepository(storageService: storage);
      final loadedGroup = await newGroupRepo.getGroupById('grp_new');
      expect(loadedGroup, isNotNull);
      expect(loadedGroup?.name, equals('مجموعة الفجر'));
    });

    test('Resiliency: Storage safely recovers from corrupted JSON without crashing', () async {
      // Intentionally write invalid malformed JSON
      await storage.writeString('alfager_users', '{corrupted_malformed_json:::');

      final corruptUserRepo = PersistentUserRepository(storageService: storage);
      final users = await corruptUserRepo.getUsers();
      // Expect clean fallback to default seed list or empty list without unhandled crash
      expect(users, isA<List<UserModel>>());
    });

    test('End-to-End: Full Wake-up Engine Journey from Pending to Prayed with persistent logs', () async {
      final mockCall = MockCallService(
        defaultBehavior: MockCallBehavior.alwaysAnswerAndPrayed,
        simulatedRingingDelay: const Duration(milliseconds: 1),
      );

      final engine = WakeUpEngine(
        callService: mockCall,
        fajrTime: DateTime.now(),
      );

      final users = [
        const UserModel(id: 'u_journey_1', name: 'ياسين', phone: '+966500000001', isOptedIn: true),
        const UserModel(id: 'u_journey_2', name: 'بلال', phone: '+966500000002', isOptedIn: true),
      ];
      engine.setUsers(users);

      await engine.runFullSession(simulationSpeed: true);

      expect(engine.sessionStatus, equals(EngineSessionStatus.completed));
      expect(engine.users.every((u) => u.status == UserStatus.prayed), isTrue);

      // Verify log count and events
      expect(engine.logs.length, greaterThanOrEqualTo(4));

      engine.dispose();
    });

    test('Edge Case: Permission Manager verifies permissions and enforces restrictions', () async {
      final permissions = await PermissionManager.verifyAllMandatoryPermissions();
      expect(permissions[AppPermissionType.notifications], isTrue);
      expect(permissions[AppPermissionType.microphone], isTrue);
    });

    test('Edge Case: Twilio Call Service safely handles empty or invalid credentials', () async {
      final unconfiguredTwilio = TwilioCallService(
        accountSid: '',
        authToken: '',
        fromPhoneNumber: '',
      );

      final prompt = engineDefaultPrompt();
      final result = await unconfiguredTwilio.makeCall(
        callId: 'call_test',
        toPhone: '+966500000000',
        prompt: prompt,
      );

      expect(result.status, equals(CallStatus.failed));
      expect(result.errorMessage, contains('بيانات اعتماد Twilio غير مكتملة'));
    });

    test('Edge Case: Backend Proxy Call Service handles network failure gracefully', () async {
      final proxyService = BackendProxyCallService(
        baseUrl: 'http://invalid-unreachable-domain-12345.local',
        apiKey: 'test_token',
      );

      final prompt = engineDefaultPrompt();
      final result = await proxyService.makeCall(
        callId: 'proxy_call_1',
        toPhone: '+966500000000',
        prompt: prompt,
        timeoutSeconds: 1,
      );

      expect(result.status, equals(CallStatus.failed));
      expect(result.errorMessage, isNotNull);
    });

    test('State Machine: Disallows illegal state transitions', () {
      // Cannot transition from prayed to calling
      final invalidTrans = WakeUpStateMachine.transition(
        currentStatus: UserStatus.prayed,
        event: WakeUpEvent.startCall,
        currentRetries: 0,
        maxRetries: 3,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: true,
      );
      expect(invalidTrans.isSuccess, isFalse);

      // Opted out user is completely blocked
      final optedOutTrans = WakeUpStateMachine.transition(
        currentStatus: UserStatus.pending,
        event: WakeUpEvent.startCall,
        currentRetries: 0,
        maxRetries: 3,
        currentSnoozes: 0,
        maxSnoozes: 2,
        isOptedIn: false,
      );
      expect(optedOutTrans.isSuccess, isFalse);
    });
  });
}

AudioPrompt engineDefaultPrompt() {
  return AudioPrompt.fromType(AudioPromptType.firstWakeUp);
}
