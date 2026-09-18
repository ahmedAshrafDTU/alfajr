import 'package:alfager/features/wird/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitForWird(String wirdId);
  Future<void> saveHabit(Habit habit);
  Future<void> calculateAndSaveHabitStrength(String wirdId); // Recalculate streak/status
}
