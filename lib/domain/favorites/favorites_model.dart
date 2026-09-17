import 'package:flutter/foundation.dart';
import '../routing/route_model.dart';

@immutable
class FavoriteRouteModel {
  final String id;
  final String title;
  final String destinationName;
  final double destLat;
  final double destLon;
  final double distanceMeters;
  final double durationSeconds;
  final String mood;
  final DateTime createdAt;

  const FavoriteRouteModel({
    required this.id,
    required this.title,
    required this.destinationName,
    required this.destLat,
    required this.destLon,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.mood,
    required this.createdAt,
  });

  String get formattedDistance => RouteResult.formatDistance(distanceMeters);
  String get formattedDuration => RouteResult.formatDuration(durationSeconds);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination_name': destinationName,
      'dest_lat': destLat,
      'dest_lon': destLon,
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavoriteRouteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteRouteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      destinationName: map['destination_name'] as String,
      destLat: (map['dest_lat'] as num).toDouble(),
      destLon: (map['dest_lon'] as num).toDouble(),
      distanceMeters: (map['distance_meters'] as num).toDouble(),
      durationSeconds: (map['duration_seconds'] as num).toDouble(),
      mood: map['mood'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
