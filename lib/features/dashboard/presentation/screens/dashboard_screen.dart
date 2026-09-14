import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../prayer_times/domain/models/prayer_times_model.dart';
import '../../../prayer_times/domain/services/prayer_calculator_service.dart';
import '../../../prayer_times/presentation/widgets/next_fajr_card.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_status.dart';
import '../../../wake_up/domain/services/wake_up_engine.dart';
import '../widgets/metric_summary_card.dart';
import '../../../wake_up/presentation/widgets/timeline_log_widget.dart';
import '../../../wake_up/presentation/screens/live_monitoring_screen.dart';
import '../../../wird/domain/repositories/wird_repository.dart';
import '../../../wird/presentation/widgets/wird_dashboard_card.dart';

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

    // Listen to live engine updates
    widget.engine.usersStream.listen((updatedUsers) {
      if (mounted) {
        setState(() {
          _users = updatedUsers;
        });
      }
    });

    widget.engine.logsStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });

    widget.engine.sessionStatusStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('بدأت جلسة إيقاظ الفجر الآن بنجاح.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _emergencyStop() {
    widget.engine.emergencyStop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إيقاف جميع المكالمات والعمليات فوراً.'),
        backgroundColor: AppColors.statusNoAnswer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = _users.length;
    final awake = _users.where((u) => u.status == UserStatus.awake || u.status == UserStatus.needsFollowUp || u.status == UserStatus.secondFollowUp || u.status == UserStatus.prayed).length;
    final prayed = _users.where((u) => u.status == UserStatus.prayed).length;
    final failed = _users.where((u) => u.status == UserStatus.failed || u.status == UserStatus.notPrayed).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mosque_rounded, color: AppColors.gold, size: 24),
            SizedBox(width: 8),
            Text(AppStrings.appName),
          ],
        ),
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
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
