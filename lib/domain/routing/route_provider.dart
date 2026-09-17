import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../services/routing_service.dart';
import 'route_model.dart';

final routingServiceProvider = Provider<RoutingService>((ref) {
  return OsrmRoutingService();
});

enum RouteStatus {
  idle,
  searching,
  loading,
  routeAvailable,
  navigationActive,
  routeError,
  locationUnavailable,
}

class RouteState {
  final RouteStatus status;
  final RouteResult? route;
  final String activeProfile; // 'foot', 'jog', 'motorcycle'
  final String? errorMessage;
  final List<LatLng> waypoints;
  final bool isOffRoute;
  final double? remainingDistanceMeters;
  final double? remainingDurationSeconds;
  final LatLng? lastKnownPosition;

  const RouteState({
    this.status = RouteStatus.idle,
    this.route,
    this.activeProfile = 'foot',
    this.errorMessage,
    this.waypoints = const [],
    this.isOffRoute = false,
    this.remainingDistanceMeters,
    this.remainingDurationSeconds,
    this.lastKnownPosition,
  });

  bool get isLoading => status == RouteStatus.loading;
  bool get isRouteAvailable => status == RouteStatus.routeAvailable || status == RouteStatus.navigationActive;
  bool get isNavigationActive => status == RouteStatus.navigationActive;
  bool get hasError => status == RouteStatus.routeError;

  String get formattedRemainingDistance {
    if (remainingDistanceMeters != null) {
      return RouteResult.formatDistance(remainingDistanceMeters!);
    }
    return route?.formattedDistance ?? '—';
  }

  String get formattedRemainingDuration {
    if (remainingDurationSeconds != null) {
      return RouteResult.formatDuration(remainingDurationSeconds!);
    }
    return route?.formattedDuration ?? '—';
  }

  RouteState copyWith({
    RouteStatus? status,
    RouteResult? route,
    bool clearRoute = false,
    String? activeProfile,
    String? errorMessage,
    List<LatLng>? waypoints,
    bool? isOffRoute,
    double? remainingDistanceMeters,
    double? remainingDurationSeconds,
    LatLng? lastKnownPosition,
  }) {
    return RouteState(
      status: status ?? this.status,
      route: clearRoute ? null : (route ?? this.route),
      activeProfile: activeProfile ?? this.activeProfile,
      errorMessage: errorMessage ?? this.errorMessage,
      waypoints: waypoints ?? this.waypoints,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      remainingDistanceMeters: remainingDistanceMeters ?? this.remainingDistanceMeters,
      remainingDurationSeconds: remainingDurationSeconds ?? this.remainingDurationSeconds,
      lastKnownPosition: lastKnownPosition ?? this.lastKnownPosition,
    );
  }
}

class RouteNotifier extends Notifier<RouteState> {
  @override
  RouteState build() {
    return const RouteState();
  }

  Future<void> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String? profile,
  }) async {
    final targetProfile = profile ?? state.activeProfile;
    final targetWaypoints = waypoints ?? state.waypoints;

    state = state.copyWith(
      status: RouteStatus.loading,
      activeProfile: targetProfile,
      waypoints: targetWaypoints,
      errorMessage: null,
      isOffRoute: false,
    );

    try {
      final routingService = ref.read(routingServiceProvider);
      final routeResult = await routingService.fetchRoute(
        origin: origin,
        destination: destination,
        waypoints: targetWaypoints,
        profile: targetProfile,
      );

      state = state.copyWith(
        status: RouteStatus.routeAvailable,
        route: routeResult,
        remainingDistanceMeters: routeResult.distanceMeters,
        remainingDurationSeconds: routeResult.durationSeconds,
        errorMessage: null,
        isOffRoute: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: RouteStatus.routeError,
        clearRoute: true,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void startNavigation() {
    if (state.route == null) return;
    state = state.copyWith(
      status: RouteStatus.navigationActive,
      isOffRoute: false,
      remainingDistanceMeters: state.route!.distanceMeters,
      remainingDurationSeconds: state.route!.durationSeconds,
    );
  }

  void updateNavigationPosition(LatLng currentPos) {
    if (state.route == null || state.status != RouteStatus.navigationActive) return;

    final route = state.route!;
    final offRouteDistance = route.distanceToPolyline(currentPos);
    
    // Threshold: > 50 meters away from route polyline indicates route deviation
    final isDeviated = offRouteDistance > 50.0;

    final remainingMeters = route.calculateRemainingDistance(currentPos);
    
    // Calculate remaining duration proportionally based on remaining distance ratio
    final ratio = route.distanceMeters > 0 ? (remainingMeters / route.distanceMeters) : 0.0;
    final remainingSeconds = route.durationSeconds * ratio.clamp(0.0, 1.0);

    state = state.copyWith(
      lastKnownPosition: currentPos,
      remainingDistanceMeters: remainingMeters,
      remainingDurationSeconds: remainingSeconds,
      isOffRoute: isDeviated,
    );
  }

  void endNavigation() {
    state = state.copyWith(
      status: state.route != null ? RouteStatus.routeAvailable : RouteStatus.idle,
      isOffRoute: false,
    );
  }

  void addWaypoint(LatLng point) {
    final updatedWaypoints = [...state.waypoints, point];
    state = state.copyWith(waypoints: updatedWaypoints);
  }

  void clearWaypoints() {
    state = state.copyWith(waypoints: const []);
  }

  void setProfile(String profile) {
    state = state.copyWith(activeProfile: profile);
  }

  void clearRoute() {
    state = state.copyWith(
      status: RouteStatus.idle,
      clearRoute: true,
      errorMessage: null,
      isOffRoute: false,
      remainingDistanceMeters: null,
      remainingDurationSeconds: null,
      waypoints: const [],
    );
  }
}

final routeProvider = NotifierProvider<RouteNotifier, RouteState>(() {
  return RouteNotifier();
});
