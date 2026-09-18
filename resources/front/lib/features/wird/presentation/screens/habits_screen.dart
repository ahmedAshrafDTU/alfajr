import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/entities/habit.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class HabitsScreen extends StatefulWidget {
  final HabitRepository habitRepository;
  final WirdRepository wirdRepository;

  const HabitsScreen({
    super.key,
    required this.habitRepository,
    required this.wirdRepository,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<Habit> _habits = [];
  Map<String, String> _wirdTitles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    final habits = await widget.habitRepository.getAllHabits();
    final wirds = await widget.wirdRepository.getAllWirds();
    
    Map<String, String> titles = {};
    for (var w in wirds) {
      titles[w.id] = w.title;
    }

    if (mounted) {
      setState(() {
        _habits = habits;
        _wirdTitles = titles;
        _isLoading = false;
      });
    }
  }

  String _getStatusText(HabitStatus status) {
    switch (status) {
      case HabitStatus.newHabit: return 'جديد';
      case HabitStatus.training: return 'تحت التدريب';
      case HabitStatus.developing: return 'في طور التكوين';
      case HabitStatus.stable: return 'عادة ثابتة';
      case HabitStatus.struggling: return 'متعثر';
    }
  }

  Color _getStatusColor(HabitStatus status) {
    switch (status) {
      case HabitStatus.newHabit: return Colors.blue;
      case HabitStatus.training: return Colors.orange;
      case HabitStatus.developing: return Colors.teal;
      case HabitStatus.stable: return Colors.green;
      case HabitStatus.struggling: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العادات والمتابعة'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _habits.isEmpty
          ? const Center(child: Text('لا توجد عادات مسجلة بعد.'))
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final title = _wirdTitles[habit.wirdId] ?? 'ورد محذوف';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(habit.status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(habit.status),
                                style: TextStyle(color: _getStatusColor(habit.status), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('🔥 الأيام المتتالية', '${habit.currentStreak} يوم'),
                            _buildStatItem('🏆 أطول سلسلة', '${habit.longestStreak} يوم'),
                            _buildStatItem('📈 آخر 30 يوم', '${(habit.completionRateLast30Days * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
