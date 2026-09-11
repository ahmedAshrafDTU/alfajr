import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/state/profile_provider.dart';
import 'features/kids/screens/kids_home_screen.dart';
import 'features/users/screens/profile_selection_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/groups/data/repositories/group_repository.dart';
import 'features/groups/presentation/screens/groups_screen.dart';
import 'features/history_analytics/data/repositories/history_repository.dart';
import 'features/history_analytics/presentation/screens/history_analytics_screen.dart';
import 'features/settings/data/repositories/settings_repository.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/users/data/repositories/user_repository.dart';
import 'features/users/presentation/screens/users_list_screen.dart';
import 'features/wake_up/domain/services/call_service.dart';
import 'features/wake_up/domain/services/wake_up_engine.dart';
import 'features/wake_up/presentation/screens/live_monitoring_screen.dart';
import 'features/wird/domain/repositories/habit_repository.dart';
import 'features/wird/domain/repositories/wird_repository.dart';
import 'features/wird/presentation/screens/wird_main_screen.dart';

class AlFajrApp extends StatefulWidget {
  final UserRepository userRepository;
  final GroupRepository groupRepository;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;
  final WirdRepository wirdRepository;
  final HabitRepository habitRepository;
  final CallService callService;

  const AlFajrApp({
    super.key,
    required this.userRepository,
    required this.groupRepository,
    required this.historyRepository,
    required this.settingsRepository,
    required this.wirdRepository,
    required this.habitRepository,
    required this.callService,
  });

  @override
  State<AlFajrApp> createState() => _AlFajrAppState();
}

class _AlFajrAppState extends State<AlFajrApp> {
  late WakeUpEngine _engine;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _engine = WakeUpEngine(callService: widget.callService);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsRepository.getSettings();
    if (mounted) {
      setState(() {
        _isDarkMode = settings.isDarkMode;
      });
    }
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (!profileProvider.hasProfiles) {
            return const ProfileSelectionScreen();
          }
          if (profileProvider.isKidsMode) {
            return const KidsHomeScreen();
          }
          return MainNavigationShell(
            engine: _engine,
            userRepository: widget.userRepository,
            groupRepository: widget.groupRepository,
            historyRepository: widget.historyRepository,
            settingsRepository: widget.settingsRepository,
            wirdRepository: widget.wirdRepository,
            habitRepository: widget.habitRepository,
            onThemeChanged: (isDark) => setState(() => _isDarkMode = isDark),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final WakeUpEngine engine;
  final UserRepository userRepository;
  final GroupRepository groupRepository;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;
  final WirdRepository wirdRepository;
  final HabitRepository habitRepository;
  final Function(bool isDark) onThemeChanged;

  const MainNavigationShell({
    super.key,
    required this.engine,
    required this.userRepository,
    required this.groupRepository,
    required this.historyRepository,
    required this.settingsRepository,
    required this.wirdRepository,
    required this.habitRepository,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        engine: widget.engine,
        userRepository: widget.userRepository,
        wirdRepository: widget.wirdRepository,
      ),
      LiveMonitoringScreen(
        engine: widget.engine,
        userRepository: widget.userRepository,
      ),
      UsersListScreen(
        userRepository: widget.userRepository,
      ),
      GroupsScreen(
        groupRepository: widget.groupRepository,
      ),
      HistoryAnalyticsScreen(
        historyRepository: widget.historyRepository,
      ),
      WirdMainScreen(
        wirdRepository: widget.wirdRepository,
        habitRepository: widget.habitRepository,
      ),
      SettingsScreen(
        settingsRepository: widget.settingsRepository,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: AppStrings.navDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_in_talk_outlined),
            selectedIcon: Icon(Icons.phone_in_talk_rounded),
            label: AppStrings.navLiveMonitoring,
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: AppStrings.navUsers,
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: AppStrings.navGroups,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: AppStrings.navHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque_rounded),
            label: 'الأوراد',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
