import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../routing/route_model.dart';
import 'history_model.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class HistoryState {
  final bool isLoading;
  final List<WalkHistoryItem> history;
  final String? errorMessage;

  const HistoryState({
    this.isLoading = false,
    this.history = const [],
    this.errorMessage,
  });

  double get totalDistanceMeters {
    return history.fold(0.0, (sum, item) => sum + item.distanceMeters);
  }

  double get totalDurationSeconds {
    return history.fold(0.0, (sum, item) => sum + item.durationSeconds);
  }

  int get totalRoutesCompleted => history.length;

  String get formattedTotalDistance {
    return RouteResult.formatDistance(totalDistanceMeters);
  }

  String get formattedTotalDuration {
    return RouteResult.formatDuration(totalDurationSeconds);
  }

  HistoryState copyWith({
    bool? isLoading,
    List<WalkHistoryItem>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    Future.microtask(() => loadHistory());
    return const HistoryState(isLoading: true);
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = ref.read(databaseServiceProvider);
      final rows = await db.getWalkHistory();
      final items = rows.map((r) => WalkHistoryItem.fromMap(r)).toList();
      state = state.copyWith(isLoading: false, history: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load walk history: $e',
      );
    }
  }

  Future<void> saveCompletedWalk({
    required double distanceMeters,
    required double durationSeconds,
    required String activityType,
    required String mood,
    required String destinationName,
  }) async {
    final item = WalkHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      completedAt: DateTime.now(),
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      activityType: activityType,
      mood: mood,
      destinationName: destinationName,
    );

    try {
      final db = ref.read(databaseServiceProvider);
      await db.insertWalkHistory(item.toMap());
      await loadHistory();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save walk history: $e');
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});
