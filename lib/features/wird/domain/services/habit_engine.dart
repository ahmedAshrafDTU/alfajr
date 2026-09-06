import 'package:alfager/features/wird/domain/entities/habit.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class HabitEngine {
  final WirdRepository wirdRepository;
  final HabitRepository habitRepository;

  // Configurable thresholds
  static const double _dailyCompletionThreshold = 0.8; // 80% to count as completed for streak
  
  HabitEngine({
    required this.wirdRepository,
    required this.habitRepository,
  });

  Future<Habit> calculateHabitStrength(String wirdId) async {
    final wird = await wirdRepository.getWirdById(wirdId);
    if (wird == null) throw Exception('Wird not found');

    // Get completions for the last 100 days to calculate streaks and status
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 100));
    
    final completions = await wirdRepository.getCompletionsForDateRange(wirdId, startDate, endDate);
    
    int currentStreak = 0;
    int longestStreak = 0;
    int activeDays = 0;
    int completedLast30Days = 0;
    
    // Calculate Streaks
    // Sort completions descending (newest first)
    completions.sort((a, b) => b.date.compareTo(a.date));
    
    DateTime? lastDate;
    bool streakBroken = false;
    
    for (var completion in completions) {
      bool isCompletedDay = _isCompletedForStreak(completion, wird.target);
      
      if (isCompletedDay) {
        activeDays++;
        
        if (!streakBroken) {
          // Check if dates are consecutive
          if (lastDate == null || _isConsecutive(lastDate, completion.date)) {
            currentStreak++;
          } else if (!_isConsecutive(lastDate, completion.date) && lastDate.difference(completion.date).inDays > 1) {
            streakBroken = true;
          }
        }
        
        // Calculate longest streak logic here...
        // For a full implementation, we'd need to iterate forward.
      } else {
        if (lastDate != null && _isConsecutive(lastDate, completion.date)) {
           streakBroken = true;
        }
      }
      
      // Calculate last 30 days
      if (completion.date.isAfter(endDate.subtract(const Duration(days: 30)))) {
        if (isCompletedDay) completedLast30Days++;
      }
      
      lastDate = completion.date;
    }

    // A more robust longest streak calculation (iterating forward)
    completions.sort((a, b) => a.date.compareTo(b.date));
    int tempStreak = 0;
    for (var completion in completions) {
      if (_isCompletedForStreak(completion, wird.target)) {
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
      }
    }

    double completionRateLast30Days = completedLast30Days / 30.0;
    
    // Determine Habit Status
    HabitStatus status = _determineHabitStatus(activeDays, completionRateLast30Days);

    final habit = Habit(
      wirdId: wirdId,
      status: status,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completionRateLast30Days: completionRateLast30Days,
      activeDays: activeDays,
    );
    
    await habitRepository.saveHabit(habit);
    return habit;
  }

  bool _isCompletedForStreak(WirdCompletion completion, int target) {
    if (completion.status == CompletionStatus.completed) return true;
    if (target > 0) {
      return (completion.completedValue / target) >= _dailyCompletionThreshold;
    }
    return false;
  }

  bool _isConsecutive(DateTime d1, DateTime d2) {
    // d1 is newer than d2
    return d1.difference(d2).inDays == 1;
  }

  HabitStatus _determineHabitStatus(int activeDays, double recentCompletionRate) {
    if (activeDays < 7) return HabitStatus.newHabit;
    if (activeDays <= 20) return HabitStatus.training;
    if (activeDays <= 40) {
      if (recentCompletionRate < 0.5) return HabitStatus.struggling;
      return HabitStatus.developing;
    }
    
    // 40+ days
    if (recentCompletionRate >= 0.7) return HabitStatus.stable;
    return HabitStatus.struggling;
  }
}
