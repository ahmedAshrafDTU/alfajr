import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';
import 'package:alfager/features/wird/presentation/screens/habits_screen.dart';
import 'package:alfager/features/wird/presentation/screens/plans_statistics_screen.dart';
import 'package:alfager/features/wird/presentation/screens/wirds_list_screen.dart';
import '../../../../core/theme/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: const Text('عبادتي'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'أورادي'),
              Tab(icon: Icon(Icons.trending_up_rounded), text: 'العادات'),
              Tab(icon: Icon(Icons.bar_chart_rounded), text: 'الإحصائيات'),
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

