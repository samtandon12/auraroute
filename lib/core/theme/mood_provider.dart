import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_tokens.dart';

const String _kMoodStorageKey = 'auraroute_selected_mood';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

/// Riverpod Notifier for managing active app mood & persistence
class MoodNotifier extends Notifier<AppMood> {
  late final SharedPreferences _prefs;

  @override
  AppMood build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final savedMoodName = _prefs.getString(_kMoodStorageKey);

    if (savedMoodName != null) {
      for (final mood in AppMood.values) {
        if (mood.name == savedMoodName) {
          return mood;
        }
      }
    }

    // Default mood per DESIGN.md
    return AppMood.quietReset;
  }

  /// Change active mood and persist selection
  Future<void> setMood(AppMood newMood) async {
    state = newMood;
    await _prefs.setString(_kMoodStorageKey, newMood.name);
  }

  /// Pick a random mood different from the current one ("Surprise Me")
  Future<void> setRandomMood() async {
    final available = AppMood.values.where((m) => m != state).toList();
    final random = Random();
    final nextMood = available[random.nextInt(available.length)];
    await setMood(nextMood);
  }
}

/// Main Provider for current Mood
final moodProvider = NotifierProvider<MoodNotifier, AppMood>(() {
  return MoodNotifier();
});
