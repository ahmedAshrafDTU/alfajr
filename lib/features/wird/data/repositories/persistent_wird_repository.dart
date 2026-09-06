import 'package:alfager/core/storage/local_storage_service.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_item.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';
import 'package:flutter/material.dart';

class PersistentWirdRepository implements WirdRepository {
  final LocalStorageService storageService;

  static const String _wirdsKey = 'wirds_data';
  static const String _wirdItemsKeyPrefix = 'wird_items_';
  static const String _completionsKeyPrefix = 'wird_completions_';

  PersistentWirdRepository({required this.storageService});

  @override
  Future<List<Wird>> getAllWirds() async {
    final data = await storageService.readJsonList(_wirdsKey);
    if (data == null) return [];
    
    return data.map((json) => _wirdFromJson(json)).toList();
  }

  @override
  Future<List<Wird>> getActiveWirds() async {
    final all = await getAllWirds();
    return all.where((w) => w.isActive).toList();
  }

  @override
  Future<Wird?> getWirdById(String id) async {
    final all = await getAllWirds();
    try {
      return all.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveWird(Wird wird) async {
    final all = await getAllWirds();
    final index = all.indexWhere((w) => w.id == wird.id);
    
    if (index >= 0) {
      all[index] = wird;
    } else {
      all.add(wird);
    }
    
    await storageService.writeJsonList(_wirdsKey, all.map((w) => _wirdToJson(w)).toList());
  }

  @override
  Future<void> deleteWird(String id) async {
    final all = await getAllWirds();
    final index = all.indexWhere((w) => w.id == id);
    if (index >= 0) {
      // Soft delete
      all[index] = all[index].copyWith(isActive: false, updatedAt: DateTime.now());
      await storageService.writeJsonList(_wirdsKey, all.map((w) => _wirdToJson(w)).toList());
    }
  }

  @override
  Future<List<WirdItem>> getWirdItems(String wirdId) async {
    final data = await storageService.readJsonList('$_wirdItemsKeyPrefix$wirdId');
    if (data == null) return [];
    
    return data.map((json) => _wirdItemFromJson(json)).toList();
  }

  @override
  Future<void> saveWirdItems(String wirdId, List<WirdItem> items) async {
    await storageService.writeJsonList(
      '$_wirdItemsKeyPrefix$wirdId', 
      items.map((i) => _wirdItemToJson(i)).toList()
    );
  }

  @override
  Future<WirdCompletion?> getCompletionForDate(String wirdId, DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final key = '$_completionsKeyPrefix$dateString';
    
    final data = await storageService.readJsonList(key);
    if (data == null) return null;
    
    try {
      final json = data.firstWhere((c) => c['wirdId'] == wirdId);
      return _completionFromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WirdCompletion>> getCompletionsForDateRange(String wirdId, DateTime startDate, DateTime endDate) async {
    List<WirdCompletion> result = [];
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      final completion = await getCompletionForDate(wirdId, current);
      if (completion != null) {
        result.add(completion);
      }
      current = current.add(const Duration(days: 1));
    }
    
    return result;
  }

  @override
  Future<List<WirdCompletion>> getAllCompletionsForDate(DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final key = '$_completionsKeyPrefix$dateString';
    
    final data = await storageService.readJsonList(key);
    if (data == null) return [];
    
    return data.map((json) => _completionFromJson(json)).toList();
  }

  @override
  Future<void> saveCompletion(WirdCompletion completion) async {
    final date = completion.date;
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final key = '$_completionsKeyPrefix$dateString';
    
    final all = await getAllCompletionsForDate(date);
    final index = all.indexWhere((c) => c.wirdId == completion.wirdId);
    
    if (index >= 0) {
      all[index] = completion;
    } else {
      all.add(completion);
    }
    
    await storageService.writeJsonList(key, all.map((c) => _completionToJson(c)).toList());
  }

  // --- Serialization Helpers ---

  Map<String, dynamic> _wirdToJson(Wird wird) {
    return {
      'id': wird.id,
      'title': wird.title,
      'description': wird.description,
      'category': wird.category,
      'type': wird.type.index,
      'target': wird.target,
      'unit': wird.unit,
      'iconCodePoint': wird.icon?.codePoint,
      'colorValue': wird.color?.value,
      'priority': wird.priority,
      'isActive': wird.isActive,
      'startDate': wird.startDate.toIso8601String(),
      'endDate': wird.endDate?.toIso8601String(),
      'schedule': wird.schedule,
      'reminderTimeHour': wird.reminderTime?.hour,
      'reminderTimeMinute': wird.reminderTime?.minute,
      'notificationEnabled': wird.notificationEnabled,
      'createdAt': wird.createdAt.toIso8601String(),
      'updatedAt': wird.updatedAt.toIso8601String(),
    };
  }

  Wird _wirdFromJson(Map<String, dynamic> json) {
    return Wird(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      type: WirdType.values[json['type'] ?? 0],
      target: json['target'] ?? 1,
      unit: json['unit'] ?? '',
      icon: json['iconCodePoint'] != null ? IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons') : null,
      color: json['colorValue'] != null ? Color(json['colorValue']) : null,
      priority: json['priority'] ?? 0,
      isActive: json['isActive'] ?? true,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      schedule: json['schedule'] ?? 'daily',
      reminderTime: json['reminderTimeHour'] != null && json['reminderTimeMinute'] != null
          ? TimeOfDay(hour: json['reminderTimeHour'], minute: json['reminderTimeMinute'])
          : null,
      notificationEnabled: json['notificationEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> _wirdItemToJson(WirdItem item) {
    return {
      'id': item.id,
      'wirdId': item.wirdId,
      'title': item.title,
      'target': item.target,
      'order': item.order,
    };
  }

  WirdItem _wirdItemFromJson(Map<String, dynamic> json) {
    return WirdItem(
      id: json['id'],
      wirdId: json['wirdId'],
      title: json['title'],
      target: json['target'] ?? 1,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> _completionToJson(WirdCompletion completion) {
    return {
      'id': completion.id,
      'wirdId': completion.wirdId,
      'date': completion.date.toIso8601String(),
      'completedValue': completion.completedValue,
      'status': completion.status.index,
      'completedAt': completion.completedAt?.toIso8601String(),
      'completedItemIds': completion.completedItemIds,
    };
  }

  WirdCompletion _completionFromJson(Map<String, dynamic> json) {
    return WirdCompletion(
      id: json['id'],
      wirdId: json['wirdId'],
      date: DateTime.parse(json['date']),
      completedValue: json['completedValue'] ?? 0,
      status: CompletionStatus.values[json['status'] ?? 0],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      completedItemIds: List<String>.from(json['completedItemIds'] ?? []),
    );
  }
}
