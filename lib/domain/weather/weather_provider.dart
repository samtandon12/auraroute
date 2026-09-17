import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/weather_service.dart';
import '../location/location_provider.dart';
import 'weather_model.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

class WeatherState {
  final bool isLoading;
  final WeatherModel? weather;
  final String? errorMessage;

  const WeatherState({
    this.isLoading = false,
    this.weather,
    this.errorMessage,
  });

  WeatherState copyWith({
    bool? isLoading,
    WeatherModel? weather,
    String? errorMessage,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WeatherNotifier extends Notifier<WeatherState> {
  @override
  WeatherState build() {
    // Watch user location changes and auto-fetch weather
    ref.listen(locationProvider, (previous, next) {
      if (next.position != null) {
        fetchWeather(
          latitude: next.position!.latitude,
          longitude: next.position!.longitude,
        );
      }
    });

    final locationState = ref.read(locationProvider);
    if (locationState.position != null) {
      Future.microtask(() {
        fetchWeather(
          latitude: locationState.position!.latitude,
          longitude: locationState.position!.longitude,
        );
      });
    }

    return const WeatherState();
  }

  Future<void> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(weatherServiceProvider);
      final weather = await service.fetchCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      state = state.copyWith(
        isLoading: false,
        weather: weather,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Weather update error: $e',
      );
    }
  }
}

final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(() {
  return WeatherNotifier();
});
