import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/places/place_model.dart';

class GeocodingService {
  final http.Client _httpClient;
  final Map<String, List<PlaceSearchResult>> _cache = {};

  GeocodingService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Search places using OpenStreetMap Nominatim API.
  /// Complies with usage policy by including custom User-Agent and caching.
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.length < 2) return [];

    if (_cache.containsKey(trimmedQuery)) {
      return _cache[trimmedQuery]!;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(trimmedQuery)}&format=json&addressdetails=1&limit=6',
    );

    final response = await _httpClient.get(
      url,
      headers: const {
        'User-Agent': 'AuraRoute/1.0 (com.auraroute.app)',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final results = jsonList
          .map((item) => PlaceSearchResult.fromJson(item as Map<String, dynamic>))
          .toList();

      _cache[trimmedQuery] = results;
      return results;
    } else {
      throw Exception('Place search failed (HTTP ${response.statusCode})');
    }
  }

  /// Search nearby places by category (e.g., 'cafe', 'park', 'viewpoint', 'restaurant') using OpenStreetMap Nominatim API.
  Future<List<PlaceSearchResult>> fetchNearbyCategoryPlaces({
    required double latitude,
    required double longitude,
    required String category,
  }) async {
    final cacheKey = 'cat_${category}_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(category)}&format=json&addressdetails=1&limit=6',
    );

    final response = await _httpClient.get(
      url,
      headers: const {
        'User-Agent': 'AuraRoute/1.0 (com.auraroute.app)',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final results = jsonList
          .map((item) => PlaceSearchResult.fromJson(item as Map<String, dynamic>))
          .toList();

      _cache[cacheKey] = results;
      return results;
    } else {
      return [];
    }
  }
}
