import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../domain/routing/route_model.dart';

/// Abstract Routing Service interface allowing easy replacement of routing providers
abstract class RoutingService {
  Future<RouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
    required String profile, // 'foot', 'jog', or 'car' (fallback for motorcycle)
  });
}

/// OSRM (Open Source Routing Machine) implementation of RoutingService
class OsrmRoutingService implements RoutingService {
  final http.Client _httpClient;

  OsrmRoutingService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<RouteResult> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
    required String profile,
  }) async {
    // Map internal profile key to OSRM API profile name
    // Note: Public OSRM only offers 'car', 'bike', 'foot'.
    // 'motorcycle' uses 'car' profile as an honest fallback until dedicated motorcycle provider is connected.
    final osrmProfile = profile == 'motorcycle' || profile == 'car' ? 'car' : 'foot';

    // Construct OSRM semicolon-separated coordinates: origin; waypoints...; destination
    final List<String> coordStrings = [
      '${origin.longitude},${origin.latitude}',
      ...waypoints.map((w) => '${w.longitude},${w.latitude}'),
      '${destination.longitude},${destination.latitude}',
    ];
    final coords = coordStrings.join(';');

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/$osrmProfile/$coords?overview=full&geometries=geojson',
    );

    final response = await _httpClient.get(
      url,
      headers: const {
        'User-Agent': 'AuraRoute/1.0 (com.auraroute.app)',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'] as List<dynamic>?;

      if (routes == null || routes.isEmpty) {
        throw Exception('No route found between these locations.');
      }

      final route = routes.first;
      final distance = (route['distance'] as num).toDouble();
      final rawDuration = (route['duration'] as num).toDouble();
      // Adjust duration for jogging mode (approx 1.7x faster than OSRM walking speed)
      final duration = profile == 'jog' ? (rawDuration / 1.7) : rawDuration;

      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;

      final points = coordinates.map((point) {
        final lon = (point[0] as num).toDouble();
        final lat = (point[1] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      final summary = route['legs'] != null && (route['legs'] as List).isNotEmpty
          ? (route['legs'][0]['summary'] as String? ?? 'Calculated Route')
          : 'Calculated Route';

      return RouteResult(
        points: points,
        distanceMeters: distance,
        durationSeconds: duration,
        profile: profile,
        summary: summary,
        waypoints: waypoints,
      );
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      throw Exception('Route calculation error: Invalid coordinates or no route exists.');
    } else {
      throw Exception('Routing service error (HTTP ${response.statusCode}).');
    }
  }
}
