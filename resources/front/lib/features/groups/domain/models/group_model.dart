import 'wake_up_config.dart';

/// Group Model representing a categorized collection of participants.
class GroupModel {
  final String id;
  final String name;
  final String description;
  final int colorValue; // For UI identification
  final bool isEnabled;
  final WakeUpConfig config;
  final List<String> userIds;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description = '',
    this.colorValue = 0xFF0D5C3A,
    this.isEnabled = true,
    this.config = const WakeUpConfig(),
    this.userIds = const [],
    required this.createdAt,
  });

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorValue,
    bool? isEnabled,
    WakeUpConfig? config,
    List<String>? userIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      isEnabled: isEnabled ?? this.isEnabled,
      config: config ?? this.config,
      userIds: userIds ?? this.userIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'isEnabled': isEnabled,
      'config': config.toJson(),
      'userIds': userIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF0D5C3A,
      isEnabled: json['isEnabled'] as bool? ?? true,
      config: json['config'] != null
          ? WakeUpConfig.fromJson(json['config'] as Map<String, dynamic>)
          : const WakeUpConfig(),
      userIds: (json['userIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
