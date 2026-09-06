enum CompletionStatus {
  completed,
  partial,
  missed,
  snoozed,
  skipped,
}

class WirdCompletion {
  final String id;
  final String wirdId;
  final DateTime date; // The date this completion record belongs to
  final int completedValue;
  final CompletionStatus status;
  final DateTime? completedAt; // Timestamp when it was actually done
  final List<String> completedItemIds; // For checkbox type wirds
  
  WirdCompletion({
    required this.id,
    required this.wirdId,
    required this.date,
    this.completedValue = 0,
    this.status = CompletionStatus.missed,
    this.completedAt,
    this.completedItemIds = const [],
  });

  WirdCompletion copyWith({
    String? id,
    String? wirdId,
    DateTime? date,
    int? completedValue,
    CompletionStatus? status,
    DateTime? completedAt,
    List<String>? completedItemIds,
  }) {
    return WirdCompletion(
      id: id ?? this.id,
      wirdId: wirdId ?? this.wirdId,
      date: date ?? this.date,
      completedValue: completedValue ?? this.completedValue,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      completedItemIds: completedItemIds ?? this.completedItemIds,
    );
  }
}
