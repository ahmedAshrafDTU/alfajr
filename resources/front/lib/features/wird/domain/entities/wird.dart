import 'package:flutter/material.dart';

enum WirdType {
  count,
  duration,
  pages,
  checkbox,
  boolean,
}

class Wird {
  final String id;
  final String title;
  final String description;
  final String category;
  final WirdType type;
  final int target; // Used for count, duration (mins), or pages
  final String unit;
  final IconData? icon;
  final Color? color;
  final int priority;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String schedule; // e.g. "daily", "weekly"
  final TimeOfDay? reminderTime;
  final bool notificationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wird({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.type,
    this.target = 1,
    this.unit = '',
    this.icon,
    this.color,
    this.priority = 0,
    this.isActive = true,
    required this.startDate,
    this.endDate,
    this.schedule = 'daily',
    this.reminderTime,
    this.notificationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Wird copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    WirdType? type,
    int? target,
    String? unit,
    IconData? icon,
    Color? color,
    int? priority,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? schedule,
    TimeOfDay? reminderTime,
    bool? notificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wird(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      schedule: schedule ?? this.schedule,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
