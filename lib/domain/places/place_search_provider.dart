import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/geocoding_service.dart';
import 'place_model.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

class PlaceSearchState {
  final bool isLoading;
  final List<PlaceSearchResult> results;
  final PlaceSearchResult? selectedPlace;
  final String? errorMessage;
  final String query;

  const PlaceSearchState({
    this.isLoading = false,
    this.results = const [],
    this.selectedPlace,
    this.errorMessage,
    this.query = '',
  });

  PlaceSearchState copyWith({
    bool? isLoading,
    List<PlaceSearchResult>? results,
    PlaceSearchResult? selectedPlace,
    bool clearSelectedPlace = false,
    String? errorMessage,
    String? query,
  }) {
    return PlaceSearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}

class PlaceSearchNotifier extends Notifier<PlaceSearchState> {
  Timer? _debounceTimer;

  @override
  PlaceSearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const PlaceSearchState();
  }

  void onQueryChanged(String query) {
    state = state.copyWith(query: query, errorMessage: null);
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final geocodingService = ref.read(geocodingServiceProvider);
        final results = await geocodingService.searchPlaces(query);
        state = state.copyWith(
          isLoading: false,
          results: results,
          errorMessage: null,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          results: [],
          errorMessage: 'Could not search places: $e',
        );
      }
    });
  }

  void selectPlace(PlaceSearchResult place) {
    state = state.copyWith(
      selectedPlace: place,
      results: [],
      query: place.title,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      clearSelectedPlace: true,
      query: '',
      results: [],
    );
  }
}

final placeSearchProvider =
    NotifierProvider<PlaceSearchNotifier, PlaceSearchState>(() {
  return PlaceSearchNotifier();
});
