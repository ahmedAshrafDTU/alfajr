import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class WirdLifecycleService {
  final WirdRepository wirdRepository;

  WirdLifecycleService({required this.wirdRepository});

  /// Evaluates and handles missing or carried-over wirds for a new day.
  /// Should be called on app startup or daily tick.
  Future<void> evaluateDailyCarryOver() async {
    final activeWirds = await wirdRepository.getActiveWirds();
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (var wird in activeWirds) {
      // Check last 7 days for uncompleted wirds to mark them missed
      // and create today's entry if it doesn't exist.
      for (int i = 1; i <= 7; i++) {
        final pastDate = todayDateOnly.subtract(Duration(days: i));
        
        // Skip dates before wird start date
        if (pastDate.isBefore(DateTime(wird.startDate.year, wird.startDate.month, wird.startDate.day))) {
          continue;
        }

        var pastCompletion = await wirdRepository.getCompletionForDate(wird.id, pastDate);
        
        if (pastCompletion == null) {
          // If no record exists, it was missed.
          pastCompletion = WirdCompletion(
            id: '${wird.id}_${pastDate.millisecondsSinceEpoch}',
            wirdId: wird.id,
            date: pastDate,
            status: CompletionStatus.missed,
          );
          await wirdRepository.saveCompletion(pastCompletion);
        } else if (pastCompletion.status == CompletionStatus.snoozed || pastCompletion.status == CompletionStatus.partial) {
            // Carry over logic could be applied here if 'User-created backlog' is enabled.
            // For now, following strict rule: Daily stays missed, Recurring starts fresh.
        }
      }
      
      // Ensure today's completion entry exists if it's scheduled for today
      // (Assuming schedule="daily" for all for simplicity in this prototype, 
      // full logic would parse schedule rules)
      if (wird.schedule == 'daily') {
         final todayCompletion = await wirdRepository.getCompletionForDate(wird.id, todayDateOnly);
         if (todayCompletion == null) {
           await wirdRepository.saveCompletion(WirdCompletion(
              id: '${wird.id}_${todayDateOnly.millisecondsSinceEpoch}',
              wirdId: wird.id,
              date: todayDateOnly,
              // Status remains default (missed/pending) until action is taken
           ));
         }
      }
    }
  }
}
