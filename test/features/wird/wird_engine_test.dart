import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/features/wird/domain/entities/habit.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/entities/wird_item.dart';
import 'package:alfager/features/wird/domain/services/habit_engine.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';
import 'package:alfager/features/wird/domain/repositories/habit_repository.dart';

// A simple mock for testing
class MockWirdRepository implements WirdRepository {
  List<WirdCompletion> completions = [];
  Wird? wird;
  
  @override
  Future<List<Wird>> getActiveWirds() async => [];
  @override
  Future<List<WirdCompletion>> getAllCompletionsForDate(DateTime date) async => [];
  @override
  Future<List<Wird>> getAllWirds() async => [];
  @override
  Future<WirdCompletion?> getCompletionForDate(String wirdId, DateTime date) async => null;
  @override
  Future<List<WirdCompletion>> getCompletionsForDateRange(String wirdId, DateTime startDate, DateTime endDate) async => completions;
  @override
  Future<Wird?> getWirdById(String id) async => wird;
  @override
  Future<List<WirdItem>> getWirdItems(String wirdId) async => [];
  @override
  Future<void> saveCompletion(WirdCompletion completion) async {}
  @override
  Future<void> saveWird(Wird wird) async {}
  @override
  Future<void> saveWirdItems(String wirdId, List<WirdItem> items) async {}
  @override
  Future<void> deleteWird(String id) async {}
}

class MockHabitRepository implements HabitRepository {
  @override
  Future<void> calculateAndSaveHabitStrength(String wirdId) async {}
  @override
  Future<List<Habit>> getAllHabits() async => [];
  @override
  Future<Habit?> getHabitForWird(String wirdId) async => null;
  @override
  Future<void> saveHabit(Habit habit) async {}
}

void main() {
  group('HabitEngine Tests', () {
    late HabitEngine engine;
    late MockWirdRepository wirdRepo;
    late MockHabitRepository habitRepo;

    setUp(() {
      wirdRepo = MockWirdRepository();
      habitRepo = MockHabitRepository();
      engine = HabitEngine(wirdRepository: wirdRepo, habitRepository: habitRepo);
      
      wirdRepo.wird = Wird(
        id: 'test_1',
        title: 'Test',
        category: 'Test',
        type: WirdType.count,
        target: 100,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('Calculate Streak with missing days breaks the streak', () async {
      final today = DateTime.now();
      wirdRepo.completions = [
        WirdCompletion(id: '1', wirdId: 'test_1', date: today, status: CompletionStatus.completed),
        WirdCompletion(id: '2', wirdId: 'test_1', date: today.subtract(const Duration(days: 1)), status: CompletionStatus.completed),
        // Day 2 is missing
        WirdCompletion(id: '3', wirdId: 'test_1', date: today.subtract(const Duration(days: 3)), status: CompletionStatus.completed),
      ];

      final habit = await engine.calculateHabitStrength('test_1');
      expect(habit.currentStreak, 2); // Only today and yesterday count
    });
  });
}
