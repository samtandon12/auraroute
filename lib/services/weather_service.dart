import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/weather/weather_model.dart';

class WeatherService {
  final http.Client _httpClient;
  WeatherModel? _cachedWeather;
  DateTime? _lastFetchTime;

  WeatherService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Fetches live weather data from Open-Meteo API using given latitude and longitude.
  Future<WeatherModel> fetchCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    // Return cache if fetched within last 10 minutes
    if (_cachedWeather != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 10) {
      return _cachedWeather!;
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m,is_day',
    );

    final response = await _httpClient.get(
      url,
      headers: const {
        'User-Agent': 'AuraRoute/1.0 (com.auraroute.app)',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      final weather = WeatherModel.fromJson(jsonMap);
      _cachedWeather = weather;
      _lastFetchTime = DateTime.now();
      return weather;
    } else {
      throw Exception('Failed to load weather data (HTTP ${response.statusCode})');
    }
  }
}
