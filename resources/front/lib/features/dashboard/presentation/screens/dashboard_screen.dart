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
  final ValueChanged<int>? onNavigate;

  const DashboardScreen({
    super.key,
    required this.engine,
    required this.userRepository,
    this.wirdRepository,
    this.onNavigate,
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
<<<<<<< HEAD
        title: const Text('الرئيسية'),
=======
        actions: [
          PopupMenuButton<int>(
            tooltip: 'المزيد',
            icon: const Icon(Icons.grid_view_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            offset: const Offset(0, 48),
            onSelected: widget.onNavigate,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 5, child: ListTile(
                leading: Icon(Icons.family_restroom_rounded),
                title: Text('لوحة الأسرة'), contentPadding: EdgeInsets.zero,
              )),
              PopupMenuItem(value: 6, child: ListTile(
                leading: Icon(Icons.mosque_rounded),
                title: Text('الأوراد والعادات'), contentPadding: EdgeInsets.zero,
              )),
              PopupMenuItem(value: 7, child: ListTile(
                leading: Icon(Icons.settings_rounded),
                title: Text('الإعدادات'), contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded),
            tooltip: 'المتابعة الحية',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LiveMonitoringScreen(
                    engine: widget.engine,
                    userRepository: widget.userRepository,
                  ),
                ),
              );
            },
          ),
        ],
>>>>>>> 19042eda4d110855f2a0a6ea22a93e533b2c6bf6
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< HEAD
              // 1. Greeting Section
              Text(
                '${_getGreeting()}،',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
=======
              // 1. Next Fajr Countdown Hero Card
              NextFajrCard(prayerTimes: _prayerTimes),
              const SizedBox(height: 16),

              // 2. Action Controls (Start Session / Emergency Stop)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: widget.engine.isRunning ? null : _startSession,
                      icon: widget.engine.isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 24),
                      label: Text(
                        widget.engine.isRunning ? 'الجلسة جارية...' : AppStrings.startWakeUpSession,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.engine.isRunning ? AppColors.amber : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: widget.engine.isRunning ? _emergencyStop : null,
                      icon: const Icon(Icons.stop_circle_rounded, color: AppColors.statusNoAnswer),
                      label: const Text(
                        'إيقاف طارئ',
                        style: TextStyle(color: AppColors.statusNoAnswer, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.statusNoAnswer, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Section Title: KPI Metrics
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'إحصائيات المتابعة اليومية',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LiveMonitoringScreen(
                            engine: widget.engine,
                            userRepository: widget.userRepository,
                          ),
                        ),
                      );
                    },
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 4. Metric Tiles Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.18,
                children: [
                  MetricSummaryCard(
                    title: AppStrings.totalUsers,
                    value: '$total',
                    subtitle: 'مسجل',
                    icon: Icons.group_rounded,
                    color: AppColors.primaryLight,
                  ),
                  MetricSummaryCard(
                    title: AppStrings.awakeUsers,
                    value: '$awake / $total',
                    subtitle: total > 0 ? '${((awake / total) * 100).toStringAsFixed(0)}%' : '0%',
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.amber,
                  ),
                  MetricSummaryCard(
                    title: AppStrings.prayedUsers,
                    value: '$prayed / $total',
                    subtitle: total > 0 ? '${((prayed / total) * 100).toStringAsFixed(0)}%' : '0%',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.statusPrayed,
                  ),
                  MetricSummaryCard(
                    title: AppStrings.failedUsers,
                    value: '$failed',
                    subtitle: 'بدون إجابة',
                    icon: Icons.phone_missed_rounded,
                    color: AppColors.statusNoAnswer,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4.5. Section: Today's Wird
              if (widget.wirdRepository != null)
                WirdDashboardCard(wirdRepository: widget.wirdRepository!),
              const SizedBox(height: 24),

              // 5. Section: Live Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الخط الزمني لجلسة اليوم (Timeline)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (widget.engine.logs.isNotEmpty)
                    Text(
                      '${widget.engine.logs.length} حدث',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TimelineLogWidget(
                    logs: widget.engine.logs,
                    isCompact: true,
                  ),
>>>>>>> 19042eda4d110855f2a0a6ea22a93e533b2c6bf6
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

