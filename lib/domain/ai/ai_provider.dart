import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/mood_provider.dart';
import '../../core/theme/mood_tokens.dart';
import '../../services/ai_service.dart';
import '../location/location_provider.dart';
import '../places/place_search_provider.dart';
import '../weather/weather_provider.dart';
import 'ai_model.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiState {
  final bool isLoading;
  final AiRecommendationResult? recommendation;
  final String? errorMessage;

  const AiState({
    this.isLoading = false,
    this.recommendation,
    this.errorMessage,
  });

  AiState copyWith({
    bool? isLoading,
    AiRecommendationResult? recommendation,
    String? errorMessage,
  }) {
    return AiState(
      isLoading: isLoading ?? this.isLoading,
      recommendation: recommendation ?? this.recommendation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AiNotifier extends Notifier<AiState> {
  @override
  AiState build() {
    return const AiState();
  }

  Future<void> generateRecommendation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final currentMood = ref.read(moodProvider);
      final locationState = ref.read(locationProvider);
      final weatherState = ref.read(weatherProvider);
      final searchState = ref.read(placeSearchProvider);

      final lat = locationState.position?.latitude ?? 37.7749;
      final lon = locationState.position?.longitude ?? -122.4194;

      final request = AiRecommendationRequest(
        mood: currentMood.displayName,
        latitude: lat,
        longitude: lon,
        weather: weatherState.weather,
        destination: searchState.selectedPlace,
        nearbyPlaces: searchState.results,
      );

      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.fetchRecommendation(request);

      state = state.copyWith(
        isLoading: false,
        recommendation: result,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not generate recommendation: $e',
      );
    }
  }
}

final aiProvider = NotifierProvider<AiNotifier, AiState>(() {
  return AiNotifier();
});
