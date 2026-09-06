import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';
import 'package:alfager/features/wird/presentation/screens/current_wird_screen.dart';

class WirdDashboardCard extends StatefulWidget {
  final WirdRepository wirdRepository;

  const WirdDashboardCard({super.key, required this.wirdRepository});

  @override
  State<WirdDashboardCard> createState() => _WirdDashboardCardState();
}

class _WirdDashboardCardState extends State<WirdDashboardCard> {
  List<Wird> _activeWirds = [];
  Map<String, WirdCompletion?> _todayCompletions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final wirds = await widget.wirdRepository.getActiveWirds();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    Map<String, WirdCompletion?> completions = {};
    for (var w in wirds) {
      completions[w.id] = await widget.wirdRepository.getCompletionForDate(w.id, todayDate);
    }

    if (mounted) {
      setState(() {
        _activeWirds = wirds;
        _todayCompletions = completions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_activeWirds.isEmpty) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('لا توجد أوراد نشطة. ابدأ بإضافة وردك الأول!', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    int completedCount = 0;
    for (var w in _activeWirds) {
      final completion = _todayCompletions[w.id];
      if (completion != null && completion.status == CompletionStatus.completed) {
        completedCount++;
      }
    }

    final progress = _activeWirds.isEmpty ? 0.0 : completedCount / _activeWirds.length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ورد اليوم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% • $completedCount / ${_activeWirds.length} أوراد',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ..._activeWirds.map((w) {
              final completion = _todayCompletions[w.id];
              final isCompleted = completion?.status == CompletionStatus.completed;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                title: Text(
                  w.title,
                  style: TextStyle(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CurrentWirdScreen(
                        wird: w,
                        wirdRepository: widget.wirdRepository,
                      ),
                    ),
                  );
                  // Refresh data when coming back
                  _loadData();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
