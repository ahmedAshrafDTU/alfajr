import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';
import 'package:alfager/features/wird/presentation/screens/habits_screen.dart';
import 'package:alfager/features/wird/presentation/screens/plans_statistics_screen.dart';
import 'package:alfager/features/wird/presentation/screens/wirds_list_screen.dart';

class WirdMainScreen extends StatelessWidget {
  final WirdRepository wirdRepository;
  final HabitRepository habitRepository;

  const WirdMainScreen({
    super.key,
    required this.wirdRepository,
    required this.habitRepository,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأوراد والعادات'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'أورادي'),
              Tab(icon: Icon(Icons.trending_up), text: 'العادات'),
              Tab(icon: Icon(Icons.bar_chart), text: 'الإحصائيات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WirdsListScreen(wirdRepository: wirdRepository),
            HabitsScreen(habitRepository: habitRepository, wirdRepository: wirdRepository),
            PlansStatisticsScreen(wirdRepository: wirdRepository),
          ],
        ),
      ),
    );
  }
}
