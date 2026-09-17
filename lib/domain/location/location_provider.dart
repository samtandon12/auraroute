import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import 'location_state.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

class LocationNotifier extends Notifier<LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  LocationState build() {
    ref.onDispose(() {
      _positionStreamSubscription?.cancel();
    });

    // Auto-initiate location check
    Future.microtask(() => initializeLocation());

    return const LocationState();
  }

  Future<void> initializeLocation() async {
    state = state.copyWith(status: LocationStatus.loading);
    final service = ref.read(locationServiceProvider);

    try {
      final serviceEnabled = await service.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          status: LocationStatus.serviceDisabled,
          errorMessage: 'Location services are disabled on this device.',
        );
        return;
      }

      var permission = await service.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await service.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            status: LocationStatus.permissionDenied,
            errorMessage: 'Location permission was denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          status: LocationStatus.permissionPermanentlyDenied,
          errorMessage:
              'Location permission is permanently denied. Please enable it in Settings.',
        );
        return;
      }

      // Fetch initial fix
      final initialPosition = await service.getCurrentPosition();
      state = state.copyWith(
        status: LocationStatus.success,
        position: initialPosition,
        errorMessage: null,
      );

      // Subscribe to live position updates with distance filter
      _startTrackingStream();
    } catch (e) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Failed to acquire location: $e',
      );
    }
  }

  void _startTrackingStream() {
    _positionStreamSubscription?.cancel();
    final service = ref.read(locationServiceProvider);

    _positionStreamSubscription = service
        .getPositionStream(distanceFilterMeters: 10)
        .listen(
      (newPosition) {
        state = state.copyWith(
          status: LocationStatus.success,
          position: newPosition,
        );
      },
      onError: (err) {
        state = state.copyWith(
          status: LocationStatus.error,
          errorMessage: 'Location stream error: $err',
        );
      },
    );
  }

  Future<void> requestPermission() async {
    await initializeLocation();
  }

  Future<void> openAppSettings() async {
    final service = ref.read(locationServiceProvider);
    await service.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    final service = ref.read(locationServiceProvider);
    await service.openLocationSettings();
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});
