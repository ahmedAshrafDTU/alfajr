import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/state/app_mode_provider.dart';
import 'core/state/profile_provider.dart';
import 'core/config/app_config.dart';
import 'core/storage/local_storage_service.dart';
import 'features/groups/data/repositories/persistent_group_repository.dart';
import 'features/history_analytics/data/repositories/persistent_history_repository.dart';
import 'features/settings/data/repositories/persistent_settings_repository.dart';
import 'features/users/data/repositories/persistent_user_repository.dart';
import 'features/wake_up/domain/services/backend_proxy_call_service.dart';
import 'features/wake_up/domain/services/call_service.dart';
import 'features/wake_up/domain/services/mock_call_service.dart';
import 'features/wake_up/domain/services/twilio_call_service.dart';
import 'features/wird/data/repositories/persistent_habit_repository.dart';
import 'features/wird/data/repositories/persistent_wird_repository.dart';
import 'features/wird/domain/services/wird_lifecycle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Durable Storage Engine
  final storageService = SharedPrefsLocalStorageService();
  await storageService.init();

  // 2. Initialize Persistent Repositories
  final userRepository = PersistentUserRepository(storageService: storageService);
  final groupRepository = PersistentGroupRepository(storageService: storageService);
  final historyRepository = PersistentHistoryRepository(storageService: storageService);
  final settingsRepository = PersistentSettingsRepository(storageService: storageService);
  final wirdRepository = PersistentWirdRepository(storageService: storageService);
  final habitRepository = PersistentHabitRepository(storageService: storageService);

  // Evaluate Daily Carry Over for Wirds
  final wirdLifecycleService = WirdLifecycleService(wirdRepository: wirdRepository);
  await wirdLifecycleService.evaluateDailyCarryOver();

  final settings = await settingsRepository.getSettings();

  // 3. Select Production / Proxy / Direct / Mock Call Provider
  CallService callService;
  if (settings.activeCallProvider == 'twilio' &&
      settings.twilioAccountSid.isNotEmpty &&
      settings.twilioAuthToken.isNotEmpty) {
    callService = TwilioCallService(
      accountSid: settings.twilioAccountSid,
      authToken: settings.twilioAuthToken,
      fromPhoneNumber: settings.twilioFromNumber,
      webhookBaseUrl: settings.webhookBaseUrl,
    );
  } else if (AppConfig.backendApiKey.isNotEmpty) {
    callService = BackendProxyCallService(
      baseUrl: AppConfig.backendBaseUrl,
      apiKey: AppConfig.backendApiKey,
    );
  } else {
    // Intelligent Simulator / Offline Mock Mode
    callService = MockCallService(
      defaultBehavior: MockCallBehavior.alwaysAnswerAndPrayed,
      simulatedRingingDelay: const Duration(seconds: 1),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppModeProvider()), // Keep for legacy if needed temporarily
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: AlFajrApp(
        userRepository: userRepository,
        groupRepository: groupRepository,
        historyRepository: historyRepository,
        settingsRepository: settingsRepository,
        wirdRepository: wirdRepository,
        habitRepository: habitRepository,
        callService: callService,
      ),
    ),
  );
}
