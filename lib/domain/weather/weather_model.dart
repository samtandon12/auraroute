import 'package:flutter/material.dart';

@immutable
class WeatherModel {
  final double temperatureCelsius;
  final double apparentTemperatureCelsius;
  final double windSpeedKmh;
  final double rainMm;
  final int weatherCode;
  final bool isDaytime;

  const WeatherModel({
    required this.temperatureCelsius,
    required this.apparentTemperatureCelsius,
    required this.windSpeedKmh,
    required this.rainMm,
    required this.weatherCode,
    this.isDaytime = true,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    return WeatherModel(
      temperatureCelsius: (current['temperature_2m'] as num? ?? 20.0).toDouble(),
      apparentTemperatureCelsius: (current['apparent_temperature'] as num? ?? 20.0).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num? ?? 5.0).toDouble(),
      rainMm: (current['rain'] as num? ?? current['precipitation'] as num? ?? 0.0).toDouble(),
      weatherCode: (current['weather_code'] as num? ?? 0).toInt(),
      isDaytime: (current['is_day'] as num? ?? 1) == 1,
    );
  }

  String get formattedTemperature => '${temperatureCelsius.round()}°C';

  String get conditionLabel {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Clear';
    }
  }

  IconData get iconData {
    switch (weatherCode) {
      case 0:
      case 1:
        return isDaytime ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
      case 2:
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.cloud_queue_rounded;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.grain_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Color get iconColor {
    if (weatherCode <= 1) return Colors.amber;
    if (weatherCode <= 3) return Colors.lightBlueAccent;
    if (weatherCode >= 50 && weatherCode <= 82) return Colors.blueAccent;
    if (weatherCode >= 95) return Colors.deepPurpleAccent;
    return Colors.amber;
  }

  bool get isOutdoorFriendly => rainMm < 1.0 && windSpeedKmh < 35.0;
}
