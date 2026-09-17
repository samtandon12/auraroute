import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/geocoding_service.dart';
import '../location/location_provider.dart';

import 'adventure_model.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

class AdventureNotifier extends Notifier<AdventureState> {
  @override
  AdventureState build() {
    return const AdventureState(
      challenges: [
        AdventureChallenge(
          id: 'c1',
          title: 'Local Spot Discovery',
          description: 'Discover a local coffee spot or park bench along your route.',
          category: 'scenic',
        ),
        AdventureChallenge(
          id: 'c2',
          title: 'Mindful Perspective',
          description: 'Pause for 30 seconds to take in a unique view or building facade.',
          category: 'nature',
        ),
      ],
    );
  }

  Future<void> fetchDiscoveryPlaces(String category) async {
    state = state.copyWith(isLoading: true, activeCategory: category, errorMessage: null);

    try {
      final locationState = ref.read(locationProvider);
      final lat = locationState.position?.latitude ?? 37.7749;
      final lon = locationState.position?.longitude ?? -122.4194;

      final geocodingService = ref.read(geocodingServiceProvider);
      final places = await geocodingService.fetchNearbyCategoryPlaces(
        latitude: lat,
        longitude: lon,
        category: category,
      );

      state = state.copyWith(
        isLoading: false,
        discoveryPlaces: places,
        activePlaceIndex: 0,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not discover nearby $category stops: $e',
      );
    }
  }

  void skipToNextPlace() {
    if (state.discoveryPlaces.isEmpty) return;
    final nextIndex = (state.activePlaceIndex + 1) % state.discoveryPlaces.length;
    state = state.copyWith(activePlaceIndex: nextIndex);
  }

  void toggleChallengeCompleted(String id) {
    final updated = state.challenges.map((c) {
      if (c.id == id) {
        return c.copyWith(isCompleted: !c.isCompleted);
      }
      return c;
    }).toList();
    state = state.copyWith(challenges: updated);
  }
}

final adventureProvider = NotifierProvider<AdventureNotifier, AdventureState>(() {
  return AdventureNotifier();
});
