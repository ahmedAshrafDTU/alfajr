import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/islamic_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../prayer_times/domain/models/prayer_times_model.dart';
import '../../../prayer_times/domain/services/prayer_calculator_service.dart';
import '../../../prayer_times/presentation/widgets/next_fajr_card.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_status.dart';
import '../../../wake_up/domain/services/wake_up_engine.dart';
import '../widgets/metric_summary_card.dart';
import '../../../wake_up/presentation/screens/live_monitoring_screen.dart';
import '../../../wird/domain/repositories/wird_repository.dart';
import '../../../wird/presentation/widgets/wird_dashboard_card.dart';
import 'package:intl/intl.dart' as intl; // Need to alias to avoid DateFormat conflict if imported elsewhere

class DashboardScreen extends StatefulWidget {
  final WakeUpEngine engine;
  final UserRepository userRepository;
  final WirdRepository? wirdRepository;

  const DashboardScreen({
    super.key,
    required this.engine,
    required this.userRepository,
    this.wirdRepository,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PrayerTimesModel _prayerTimes;
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prayerTimes = PrayerCalculatorService.calculate(date: DateTime.now());
    _loadInitialData();

    widget.engine.usersStream.listen((updatedUsers) {
      if (mounted) setState(() => _users = updatedUsers);
    });

    widget.engine.sessionStatusStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadInitialData() async {
    final loadedUsers = await widget.userRepository.getUsers();
    widget.engine.setUsers(loadedUsers);
    if (mounted) {
      setState(() {
        _users = loadedUsers;
        _isLoading = false;
      });
    }
  }

  void _startSession() {
    if (widget.engine.isRunning) return;
    widget.engine.runFullSession(simulationSpeed: true);
  }

  void _emergencyStop() {
    widget.engine.emergencyStop();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 17) return 'طاب مساؤك';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('الرئيسية'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Greeting Section
              Text(
                '${_getGreeting()}،',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                intl.DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Hero Section: Next Fajr Card
              Hero(
                tag: 'fajr_card',
                child: NextFajrCard(prayerTimes: _prayerTimes),
              ),
              const SizedBox(height: 24),

              // 3. Today's Wird Section
              if (widget.wirdRepository != null) ...[
                Text(
                  'أوراد اليوم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                WirdDashboardCard(wirdRepository: widget.wirdRepository!),
                const SizedBox(height: 24),
              ],

              // 4. Wake-Up Engine Controls (Modernized)
              Text(
                'نظام إيقاظ الفجر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              IslamicCard(
                hasPattern: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.engine.isRunning 
                                ? AppColors.warning.withOpacity(0.1) 
                                : AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.engine.isRunning ? Icons.podcasts_rounded : Icons.sensors_off_rounded,
                            color: widget.engine.isRunning ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.engine.isRunning ? 'الجلسة قيد التشغيل' : 'الجلسة متوقفة',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_users.length} مستخدمين مسجلين',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PremiumButton(
                            label: widget.engine.isRunning ? 'توقف' : 'بدء المتابعة',
                            onPressed: widget.engine.isRunning ? _emergencyStop : _startSession,
                            isSecondary: widget.engine.isRunning,
                            icon: widget.engine.isRunning ? Icons.stop_circle_rounded : Icons.play_arrow_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: PremiumButton(
                            label: 'المراقبة',
                            isSecondary: true,
                            icon: Icons.remove_red_eye_rounded,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => LiveMonitoringScreen(
                                  engine: widget.engine,
                                  userRepository: widget.userRepository,
                                ),
                              ));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

