import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/models/analytics_model.dart';
import '../../domain/models/daily_session_history.dart';
import '../../../dashboard/presentation/widgets/metric_summary_card.dart';

class HistoryAnalyticsScreen extends StatefulWidget {
  final HistoryRepository historyRepository;

  const HistoryAnalyticsScreen({super.key, required this.historyRepository});

  @override
  State<HistoryAnalyticsScreen> createState() => _HistoryAnalyticsScreenState();
}

class _HistoryAnalyticsScreenState extends State<HistoryAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DailySessionHistory> _historyList = [];
  AnalyticsModel? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await widget.historyRepository.getHistory();
    final analytics = await widget.historyRepository.getAnalytics();
    if (mounted) {
      setState(() {
        _historyList = history;
        _analytics = analytics;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navHistory),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.insights_rounded), text: 'الإحصائيات العامة'),
            Tab(icon: Icon(Icons.history_rounded), text: 'أرشيف الجلسات اليومية'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Analytics & Metrics
                _buildAnalyticsTab(),

                // Tab 2: Daily Sessions History List
                _buildHistoryListTab(),
              ],
            ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            children: [
              MetricSummaryCard(
                title: 'معدل الاستيقاظ العام',
                value: '${_analytics!.overallWakeUpRate.toStringAsFixed(1)}%',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.amber,
              ),
              MetricSummaryCard(
                title: 'معدل إتمام الصلاة',
                value: '${_analytics!.overallPrayerConfirmationRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle_rounded,
                color: AppColors.statusPrayed,
              ),
              MetricSummaryCard(
                title: 'متوسط المحاولات',
                value: '${_analytics!.averageRetriesPerUser}',
                subtitle: 'محاولة / مستخدم',
                icon: Icons.replay_rounded,
                color: AppColors.primaryLight,
              ),
              MetricSummaryCard(
                title: 'إجمالي الجلسات',
                value: '${_analytics!.totalSessionsConducted}',
                subtitle: 'جلسة مكتملة',
                icon: Icons.calendar_month_rounded,
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Trend Bar Graph
          const Text('المعدل الأسبوعي للاستيقاظ والصلاة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _analytics!.weeklyTrends.map((trend) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(trend.dayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('صلاة: ${trend.prayerRate}% | استيقاظ: ${trend.wakeUpRate}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (trend.wakeUpRate / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.amber.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (trend.prayerRate / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.statusPrayed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Most Consistent Participants
          const Text('أكثر المشتركين التزاماً واستجابة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: _analytics!.topConsistentUsers.map((u) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x2010B981),
                    child: Icon(Icons.star_rounded, color: AppColors.statusPrayed),
                  ),
                  title: Text(u.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${u.metricCount} صلاة مؤكدة بنجاح'),
                  trailing: Text(
                    '${u.percentage}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusPrayed, fontSize: 15),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryListTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyList.length,
      itemBuilder: (context, index) {
        final session = _historyList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              ArabicDateFormatter.formatDate(session.date),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              'الفجر: ${ArabicDateFormatter.formatTime(session.fajrTime)} | استيقظوا: ${session.awakeCount}/${session.totalParticipants} | صلوا: ${session.prayedCount}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            leading: CircleAvatar(
              backgroundColor: session.wakeUpSuccessRate >= 80
                  ? AppColors.statusPrayed.withOpacity(0.2)
                  : AppColors.amber.withOpacity(0.2),
              child: Icon(
                session.wakeUpSuccessRate >= 80 ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: session.wakeUpSuccessRate >= 80 ? AppColors.statusPrayed : AppColors.amber,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('نسبة الاستيقاظ', '${session.wakeUpSuccessRate.toStringAsFixed(0)}%', AppColors.amber),
                        _buildSummaryItem('نسبة أداء الصلاة', '${session.prayerConfirmationRate.toStringAsFixed(0)}%', AppColors.statusPrayed),
                        _buildSummaryItem('لم يجيبوا', '${session.failedCount}', AppColors.statusNoAnswer),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
