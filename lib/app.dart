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
import 'features/dashboard/presentation/screens/parent_dashboard_screen.dart';
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
    // Only Dashboard and Ibadah in the main view
    final screens = [
      DashboardScreen(
        engine: widget.engine,
        userRepository: widget.userRepository,
        wirdRepository: widget.wirdRepository,
      ),
      WirdMainScreen(
        wirdRepository: widget.wirdRepository,
        habitRepository: widget.habitRepository,
      ),
    ];

    return Scaffold(
      drawer: AppDrawer(
        engine: widget.engine,
        userRepository: widget.userRepository,
        groupRepository: widget.groupRepository,
        historyRepository: widget.historyRepository,
        settingsRepository: widget.settingsRepository,
        onThemeChanged: widget.onThemeChanged,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: screens[_currentIndex], // Key is needed for AnimatedSwitcher if they are same type, but they are different types here.
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'عبادتي',
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final WakeUpEngine engine;
  final UserRepository userRepository;
  final GroupRepository groupRepository;
  final HistoryRepository historyRepository;
  final SettingsRepository settingsRepository;
  final Function(bool isDark) onThemeChanged;

  const AppDrawer({
    super.key,
    required this.engine,
    required this.userRepository,
    required this.groupRepository,
    required this.historyRepository,
    required this.settingsRepository,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF0C4A34), const Color(0xFF072D20)]
                      : [const Color(0xFF0C4A34), const Color(0xFF137351)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.mosque, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'الفجر',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'نظام إسلامي متكامل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.phone_in_talk_rounded,
              title: AppStrings.navLiveMonitoring,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMonitoringScreen(
                  engine: engine,
                  userRepository: userRepository,
                )));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.people_rounded,
              title: AppStrings.navUsers,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => UsersListScreen(
                  userRepository: userRepository,
                )));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.groups_rounded,
              title: AppStrings.navGroups,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => GroupsScreen(
                  groupRepository: groupRepository,
                )));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart_rounded,
              title: AppStrings.navHistory,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryAnalyticsScreen(
                  historyRepository: historyRepository,
                )));
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.family_restroom_rounded,
              title: 'الأسرة والأطفال',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
              },
            ),
            const Divider(),
            _buildDrawerItem(
              context,
              icon: Icons.settings_rounded,
              title: AppStrings.navSettings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(
                  settingsRepository: settingsRepository,
                  onThemeChanged: onThemeChanged,
                )));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
