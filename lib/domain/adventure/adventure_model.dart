import 'package:flutter/foundation.dart';
import '../places/place_model.dart';

@immutable
class AdventureChallenge {
  final String id;
  final String title;
  final String description;
  final String category; // 'food', 'scenic', 'nature', 'mindful'
  final bool isCompleted;

  const AdventureChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
  });

  AdventureChallenge copyWith({bool? isCompleted}) {
    return AdventureChallenge(
      id: id,
      title: title,
      description: description,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@immutable
class AdventureState {
  final bool isLoading;
  final String activeCategory; // 'cafe', 'park', 'viewpoint', 'restaurant'
  final List<PlaceSearchResult> discoveryPlaces;
  final List<AdventureChallenge> challenges;
  final int activePlaceIndex;
  final String? errorMessage;

  const AdventureState({
    this.isLoading = false,
    this.activeCategory = 'cafe',
    this.discoveryPlaces = const [],
    this.challenges = const [],
    this.activePlaceIndex = 0,
    this.errorMessage,
  });

  PlaceSearchResult? get activePlace {
    if (discoveryPlaces.isEmpty) return null;
    return discoveryPlaces[activePlaceIndex % discoveryPlaces.length];
  }

  AdventureState copyWith({
    bool? isLoading,
    String? activeCategory,
    List<PlaceSearchResult>? discoveryPlaces,
    List<AdventureChallenge>? challenges,
    int? activePlaceIndex,
    String? errorMessage,
  }) {
    return AdventureState(
      isLoading: isLoading ?? this.isLoading,
      activeCategory: activeCategory ?? this.activeCategory,
      discoveryPlaces: discoveryPlaces ?? this.discoveryPlaces,
      challenges: challenges ?? this.challenges,
      activePlaceIndex: activePlaceIndex ?? this.activePlaceIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
