import 'package:flutter/foundation.dart';
import '../routing/route_model.dart';

@immutable
class WalkHistoryItem {
  final String id;
  final DateTime completedAt;
  final double distanceMeters;
  final double durationSeconds;
  final String activityType; // 'Walk', 'Jog', 'Motorcycle'
  final String mood;
  final String destinationName;

  const WalkHistoryItem({
    required this.id,
    required this.completedAt,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.activityType,
    required this.mood,
    required this.destinationName,
  });

  String get formattedDistance => RouteResult.formatDistance(distanceMeters);

  String get formattedDuration => RouteResult.formatDuration(durationSeconds);

  String get formattedDate {
    return '${completedAt.day}/${completedAt.month}/${completedAt.year}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'completed_at': completedAt.toIso8601String(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'activity_type': activityType,
      'mood': mood,
      'destination_name': destinationName,
    };
  }

  factory WalkHistoryItem.fromMap(Map<String, dynamic> map) {
    return WalkHistoryItem(
      id: map['id'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
      distanceMeters: (map['distance_meters'] as num).toDouble(),
      durationSeconds: (map['duration_seconds'] as num).toDouble(),
      activityType: map['activity_type'] as String,
      mood: map['mood'] as String,
      destinationName: map['destination_name'] as String,
    );
  }
}
