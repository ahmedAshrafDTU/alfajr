import 'package:alfager/core/storage/local_storage_service.dart';
import 'package:alfager/features/wird/domain/entities/habit.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';

class PersistentHabitRepository implements HabitRepository {
  final LocalStorageService storageService;

  static const String _habitsKey = 'habits_data';

  PersistentHabitRepository({required this.storageService});

  @override
  Future<List<Habit>> getAllHabits() async {
    final data = await storageService.readJsonList(_habitsKey);
    if (data == null) return [];
    
    return data.map((json) => _habitFromJson(json)).toList();
  }

  @override
  Future<Habit?> getHabitForWird(String wirdId) async {
    final all = await getAllHabits();
    try {
      return all.firstWhere((h) => h.wirdId == wirdId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final all = await getAllHabits();
    final index = all.indexWhere((h) => h.wirdId == habit.wirdId);
    
    if (index >= 0) {
      all[index] = habit;
    } else {
      all.add(habit);
    }
    
    await storageService.writeJsonList(_habitsKey, all.map((h) => _habitToJson(h)).toList());
  }

  @override
  Future<void> calculateAndSaveHabitStrength(String wirdId) async {
    // Note: The actual calculation is done in HabitEngine. 
    // This method is kept for interface compliance, but should ideally 
    // be removed from the repository interface or properly implemented if the repository 
    // is meant to abstract the engine.
    // For now, we will do nothing here to avoid UnimplementedError.
  }

  // --- Serialization Helpers ---

  Map<String, dynamic> _habitToJson(Habit habit) {
    return {
      'wirdId': habit.wirdId,
      'status': habit.status.index,
      'currentStreak': habit.currentStreak,
      'longestStreak': habit.longestStreak,
      'completionRateLast30Days': habit.completionRateLast30Days,
      'activeDays': habit.activeDays,
    };
  }

  Habit _habitFromJson(Map<String, dynamic> json) {
    return Habit(
      wirdId: json['wirdId'],
      status: HabitStatus.values[json['status'] ?? 0],
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completionRateLast30Days: json['completionRateLast30Days']?.toDouble() ?? 0.0,
      activeDays: json['activeDays'] ?? 0,
    );
  }
}
