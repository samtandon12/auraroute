import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import 'favorites_model.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class FavoritesState {
  final bool isLoading;
  final List<FavoriteRouteModel> favorites;
  final String? errorMessage;

  const FavoritesState({
    this.isLoading = false,
    this.favorites = const [],
    this.errorMessage,
  });

  FavoritesState copyWith({
    bool? isLoading,
    List<FavoriteRouteModel>? favorites,
    String? errorMessage,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    Future.microtask(() => loadFavorites());
    return const FavoritesState(isLoading: true);
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = ref.read(databaseServiceProvider);
      final rows = await db.getFavoriteRoutes();
      final items = rows.map((r) => FavoriteRouteModel.fromMap(r)).toList();
      state = state.copyWith(isLoading: false, favorites: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load favorite routes: $e',
      );
    }
  }

  Future<void> saveFavorite({
    required String title,
    required String destinationName,
    required double destLat,
    required double destLon,
    required double distanceMeters,
    required double durationSeconds,
    required String mood,
  }) async {
    final item = FavoriteRouteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      destinationName: destinationName,
      destLat: destLat,
      destLon: destLon,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      mood: mood,
      createdAt: DateTime.now(),
    );

    try {
      final db = ref.read(databaseServiceProvider);
      await db.insertFavoriteRoute(item.toMap());
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save favorite route: $e');
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      final db = ref.read(databaseServiceProvider);
      await db.deleteFavoriteRoute(id);
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete favorite route: $e');
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(() {
  return FavoritesNotifier();
});
