import 'package:flutter/foundation.dart';
import '../places/place_model.dart';
import '../weather/weather_model.dart';

@immutable
class AiRecommendationRequest {
  final String mood;
  final double latitude;
  final double longitude;
  final WeatherModel? weather;
  final PlaceSearchResult? destination;
  final List<PlaceSearchResult> nearbyPlaces;

  const AiRecommendationRequest({
    required this.mood,
    required this.latitude,
    required this.longitude,
    this.weather,
    this.destination,
    this.nearbyPlaces = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'weather': weather != null
          ? {
              'temperature': weather!.temperatureCelsius,
              'condition': weather!.conditionLabel,
              'rainMm': weather!.rainMm,
              'windSpeedKmh': weather!.windSpeedKmh,
            }
          : null,
      'destination': destination != null
          ? {
              'title': destination!.title,
              'subtitle': destination!.subtitle,
              'latitude': destination!.latitude,
              'longitude': destination!.longitude,
            }
          : null,
      'nearbyPlaces': nearbyPlaces
          .map((p) => {
                'title': p.title,
                'subtitle': p.subtitle,
                'latitude': p.latitude,
                'longitude': p.longitude,
              })
          .toList(),
    };
  }
}

@immutable
class AiRecommendationResult {
  final String title;
  final String recommendation;
  final String reason;
  final List<String> challenges;
  final String encouragement;
  final bool isFallback;

  const AiRecommendationResult({
    required this.title,
    required this.recommendation,
    required this.reason,
    required this.challenges,
    required this.encouragement,
    this.isFallback = false,
  });

  factory AiRecommendationResult.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    final challengesList = json['challenges'] as List<dynamic>? ?? [];
    return AiRecommendationResult(
      title: json['title'] as String? ?? 'Mood-Aware Exploration',
      recommendation: json['recommendation'] as String? ?? 'Explore your surroundings',
      reason: json['reason'] as String? ?? 'Curated for your current energy level and weather.',
      challenges: challengesList.map((c) => c.toString()).toList(),
      encouragement: json['encouragement'] as String? ?? 'Enjoy your walk today!',
      isFallback: isFallback,
    );
  }
}
