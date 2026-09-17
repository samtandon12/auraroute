import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final String profile; // 'foot', 'jog', 'motorcycle' (mapped to OSRM profile)
  final String summary;
  final List<LatLng> waypoints;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.profile,
    required this.summary,
    this.waypoints = const [],
  });

  String get formattedDistance => formatDistance(distanceMeters);

  String get formattedDuration => formatDuration(durationSeconds);

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remMinutes = minutes % 60;
    return remMinutes > 0 ? '${hours}h ${remMinutes}m' : '${hours}h';
  }

  /// Finds the index of the closest point on the route polyline to [userPos]
  int findClosestPointIndex(LatLng userPos) {
    if (points.isEmpty) return 0;
    const distanceCalc = Distance();
    int minIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final dist = distanceCalc.as(LengthUnit.Meter, userPos, points[i]);
      if (dist < minDistance) {
        minDistance = dist;
        minIndex = i;
      }
    }
    return minIndex;
  }

  /// Calculates perpendicular distance (in meters) from [userPos] to the nearest point on the route polyline
  double distanceToPolyline(LatLng userPos) {
    if (points.isEmpty) return 0.0;
    const distanceCalc = Distance();
    double minDistance = double.infinity;

    for (final point in points) {
      final dist = distanceCalc.as(LengthUnit.Meter, userPos, point);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }
    return minDistance;
  }

  /// Calculates remaining distance (in meters) along the route polyline from [userPos] to the destination
  double calculateRemainingDistance(LatLng userPos) {
    if (points.isEmpty) return 0.0;
    final closestIdx = findClosestPointIndex(userPos);
    const distanceCalc = Distance();
    
    // Direct distance from user to closest polyline point
    double totalMeters = distanceCalc.as(LengthUnit.Meter, userPos, points[closestIdx]);

    // Accumulate distance along remaining polyline segments
    for (int i = closestIdx; i < points.length - 1; i++) {
      totalMeters += distanceCalc.as(LengthUnit.Meter, points[i], points[i + 1]);
    }
    return totalMeters;
  }
}
