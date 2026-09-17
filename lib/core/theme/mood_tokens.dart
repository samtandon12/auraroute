import 'package:flutter/material.dart';

/// AuraRoute's 4 core moods
enum AppMood {
  neonRain,
  quietReset,
  mainCharacterWalk,
  goldenHourGrind,
}

extension AppMoodX on AppMood {
  String get displayName {
    switch (this) {
      case AppMood.neonRain:
        return 'Neon Rain';
      case AppMood.quietReset:
        return 'Quiet Reset';
      case AppMood.mainCharacterWalk:
        return 'Main Character Walk';
      case AppMood.goldenHourGrind:
        return 'Golden Hour Grind';
    }
  }

  String get description {
    switch (this) {
      case AppMood.neonRain:
        return 'Cyberpunk nighttime aesthetic with glowing cyan & purple tones';
      case AppMood.quietReset:
        return 'Calming organic sage greens for peaceful restorative strolls';
      case AppMood.mainCharacterWalk:
        return 'Warm cinematic amber & rose for high energy confidence walks';
      case AppMood.goldenHourGrind:
        return 'Rich bronze & sunset gold for productive deep focus journeys';
    }
  }

  String get vibeEmoji {
    switch (this) {
      case AppMood.neonRain:
        return '🌧️⚡';
      case AppMood.quietReset:
        return '🍃🧘';
      case AppMood.mainCharacterWalk:
        return '✨🚶';
      case AppMood.goldenHourGrind:
        return '🌅☕';
    }
  }

  AppMoodColors get colors {
    switch (this) {
      case AppMood.neonRain:
        return const AppMoodColors(
          background: Color(0xFF0A0E1A),
          surface: Color(0xFF11162A),
          text: Color(0xFFEEF1FF),
          mutedText: Color(0xFF9AA3C9),
          accent: Color(0xFFB26BFF),
          accent2: Color(0xFF26F0E0),
          mapLines: Color(0xFF2A2F55),
          route: Color(0xFF26F0E0),
          isDark: true,
        );
      case AppMood.quietReset:
        return const AppMoodColors(
          background: Color(0xFFEEF3EE),
          surface: Color(0xFFFFFFFF),
          text: Color(0xFF1F2E28),
          mutedText: Color(0xFF5C6D64),
          accent: Color(0xFF6F9C85),
          accent2: Color(0xFFB7CDBF),
          mapLines: Color(0xFFD3E0D8),
          route: Color(0xFF6F9C85),
          isDark: false,
        );
      case AppMood.mainCharacterWalk:
        return const AppMoodColors(
          background: Color(0xFFFFF2E2),
          surface: Color(0xFFFFFAF3),
          text: Color(0xFF3B2318),
          mutedText: Color(0xFF8A6A54),
          accent: Color(0xFFE8933D),
          accent2: Color(0xFFD9707A),
          mapLines: Color(0xFFF0D8BD),
          route: Color(0xFFD9707A),
          isDark: false,
        );
      case AppMood.goldenHourGrind:
        return const AppMoodColors(
          background: Color(0xFF241812),
          surface: Color(0xFF2F2018),
          text: Color(0xFFF4E9DC),
          mutedText: Color(0xFFC3A688),
          accent: Color(0xFFC99A63),
          accent2: Color(0xFFE8C78F),
          mapLines: Color(0xFF4A3728),
          route: Color(0xFFE8C78F),
          isDark: true,
        );
    }
  }
}

/// Strongly typed color values for a given mood
@immutable
class AppMoodColors {
  final Color background;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color accent;
  final Color accent2;
  final Color mapLines;
  final Color route;
  final bool isDark;

  const AppMoodColors({
    required this.background,
    required this.surface,
    required this.text,
    required this.mutedText,
    required this.accent,
    required this.accent2,
    required this.mapLines,
    required this.route,
    required this.isDark,
  });

  AppMoodColors lerp(AppMoodColors other, double t) {
    return AppMoodColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accent2: Color.lerp(accent2, other.accent2, t)!,
      mapLines: Color.lerp(mapLines, other.mapLines, t)!,
      route: Color.lerp(route, other.route, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
