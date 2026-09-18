import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_item.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';

abstract class WirdRepository {
  Future<List<Wird>> getAllWirds();
  Future<List<Wird>> getActiveWirds();
  Future<Wird?> getWirdById(String id);
  Future<void> saveWird(Wird wird);
  Future<void> deleteWird(String id); // Mark as inactive or soft delete to preserve history
  
  Future<List<WirdItem>> getWirdItems(String wirdId);
  Future<void> saveWirdItems(String wirdId, List<WirdItem> items);
  
  Future<WirdCompletion?> getCompletionForDate(String wirdId, DateTime date);
  Future<List<WirdCompletion>> getCompletionsForDateRange(String wirdId, DateTime startDate, DateTime endDate);
  Future<List<WirdCompletion>> getAllCompletionsForDate(DateTime date);
  Future<void> saveCompletion(WirdCompletion completion);
}
