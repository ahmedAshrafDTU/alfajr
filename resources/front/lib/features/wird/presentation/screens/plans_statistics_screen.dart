import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class PlansStatisticsScreen extends StatefulWidget {
  final WirdRepository wirdRepository;

  const PlansStatisticsScreen({super.key, required this.wirdRepository});

  @override
  State<PlansStatisticsScreen> createState() => _PlansStatisticsScreenState();
}

class _PlansStatisticsScreenState extends State<PlansStatisticsScreen> {
  // In a full implementation, this screen would fetch comprehensive history
  // and render charts. For this MVP, we show a basic UI structure.

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات والخطط'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'أسبوعي'),
              Tab(text: 'شهري'),
              Tab(text: 'سنوي'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WeeklyPlanView(),
            _MonthlyPlanView(),
            _YearlyPlanView(),
          ],
        ),
      ),
    );
  }
}

class _WeeklyPlanView extends StatelessWidget {
  const _WeeklyPlanView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('إنجاز الأسبوع الحالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDayBar('السبت', 0.8),
        _buildDayBar('الأحد', 0.6),
        _buildDayBar('الإثنين', 0.7),
        _buildDayBar('الثلاثاء', 0.8),
        _buildDayBar('الأربعاء', 0.5),
        _buildDayBar('الخميس', 0.7),
        _buildDayBar('الجمعة', 0.9),
      ],
    );
  }

  Widget _buildDayBar(String day, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(day)),
          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              color: Colors.green,
              backgroundColor: Colors.grey[200],
            ),
          ),
          SizedBox(width: 50, child: Text('  ${(percent * 100).toStringAsFixed(0)}%', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _MonthlyPlanView extends StatelessWidget {
  const _MonthlyPlanView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('خريطة الإنجاز الشهري (Calendar Heatmap)'));
  }
}

class _YearlyPlanView extends StatelessWidget {
  const _YearlyPlanView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('إحصائيات الإنجاز السنوي'));
  }
}
