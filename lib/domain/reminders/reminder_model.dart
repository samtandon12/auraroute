import 'package:flutter/foundation.dart';

@immutable
class ReminderModel {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final String activityType; // 'Walk', 'Jog', 'Motorcycle'
  final String mood;
  final bool isEnabled;
  final int notificationId;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.activityType,
    required this.mood,
    this.isEnabled = true,
    required this.notificationId,
  });

  String get formattedTime {
    final hour = scheduledAt.hour;
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$formattedHour:$minute $period';
  }

  String get formattedDate {
    return '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'scheduled_at': scheduledAt.toIso8601String(),
      'activity_type': activityType,
      'mood': mood,
      'is_enabled': isEnabled ? 1 : 0,
      'notification_id': notificationId,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      activityType: map['activity_type'] as String,
      mood: map['mood'] as String,
      isEnabled: (map['is_enabled'] as int) == 1,
      notificationId: map['notification_id'] as int,
    );
  }

  ReminderModel copyWith({
    String? title,
    DateTime? scheduledAt,
    String? activityType,
    String? mood,
    bool? isEnabled,
  }) {
    return ReminderModel(
      id: id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      activityType: activityType ?? this.activityType,
      mood: mood ?? this.mood,
      isEnabled: isEnabled ?? this.isEnabled,
      notificationId: notificationId,
    );
  }
}
