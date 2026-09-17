import 'package:flutter/foundation.dart';

@immutable
class PlaceSearchResult {
  final String id;
  final String displayName;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;

  const PlaceSearchResult({
    required this.id,
    required this.displayName,
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) {
    final displayName = json['display_name'] as String? ?? '';
    final parts = displayName.split(',');
    final title = parts.isNotEmpty ? parts.first.trim() : displayName;
    final subtitle = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

    return PlaceSearchResult(
      id: json['place_id']?.toString() ?? json['osm_id']?.toString() ?? title,
      displayName: displayName,
      title: title,
      subtitle: subtitle,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
    );
  }
}
