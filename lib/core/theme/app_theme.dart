import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_tokens.dart';

/// Flutter ThemeExtension for accessing AuraRoute mood colors cleanly in widgets
/// via `Theme.of(context).extension<AppMoodTheme>()!` or helper context extension.
@immutable
class AppMoodTheme extends ThemeExtension<AppMoodTheme> {
  final AppMood mood;
  final AppMoodColors moodColors;

  const AppMoodTheme({
    required this.mood,
    required this.moodColors,
  });

  @override
  AppMoodTheme copyWith({
    AppMood? mood,
    AppMoodColors? moodColors,
  }) {
    return AppMoodTheme(
      mood: mood ?? this.mood,
      moodColors: moodColors ?? this.moodColors,
    );
  }

  @override
  AppMoodTheme lerp(ThemeExtension<AppMoodTheme>? other, double t) {
    if (other is! AppMoodTheme) return this;
    return AppMoodTheme(
      mood: t < 0.5 ? mood : other.mood,
      moodColors: moodColors.lerp(other.moodColors, t),
    );
  }
}

/// Theme builder converting [AppMood] into a full Flutter [ThemeData]
class AppTheme {
  static ThemeData buildThemeData(AppMood mood) {
    final colors = mood.colors;
    final brightness = colors.isDark ? Brightness.dark : Brightness.light;

    final baseTextTheme = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    final spaceGroteskTheme = GoogleFonts.spaceGroteskTextTheme(baseTextTheme);
    final interTheme = GoogleFonts.interTextTheme(baseTextTheme);

    final textTheme = TextTheme(
      // Headlines & Titles -> Space Grotesk
      displayLarge: spaceGroteskTheme.displayLarge?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: spaceGroteskTheme.displayMedium?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: spaceGroteskTheme.displaySmall?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: spaceGroteskTheme.headlineLarge?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: spaceGroteskTheme.headlineMedium?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: spaceGroteskTheme.headlineSmall?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: spaceGroteskTheme.titleLarge?.copyWith(
        color: colors.text,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: spaceGroteskTheme.titleMedium?.copyWith(
        color: colors.text,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: spaceGroteskTheme.titleSmall?.copyWith(
        color: colors.text,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),

      // Body & UI -> Inter
      bodyLarge: interTheme.bodyLarge?.copyWith(
        color: colors.text,
        fontSize: 14,
        height: 1.45,
      ),
      bodyMedium: interTheme.bodyMedium?.copyWith(
        color: colors.text,
        fontSize: 13,
        height: 1.4,
      ),
      bodySmall: interTheme.bodySmall?.copyWith(
        color: colors.mutedText,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: interTheme.labelLarge?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: interTheme.labelMedium?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: interTheme.labelSmall?.copyWith(
        color: colors.mutedText,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.isDark ? colors.background : colors.surface,
        secondary: colors.accent2,
        onSecondary: colors.text,
        error: const Color(0xFFE57373),
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.text,
        surfaceContainerHighest: colors.surface,
        outline: colors.mutedText.withValues(alpha: 0.3),
      ),
      textTheme: textTheme,
      iconTheme: IconThemeData(
        color: colors.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        foregroundColor: colors.text,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.mutedText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: [
        AppMoodTheme(mood: mood, moodColors: colors),
      ],
    );
  }
}

/// Helper context extension for quick access to mood tokens
extension AppMoodContextX on BuildContext {
  AppMoodTheme get moodTheme =>
      Theme.of(this).extension<AppMoodTheme>() ??
      AppMoodTheme(
        mood: AppMood.neonRain,
        moodColors: AppMood.neonRain.colors,
      );

  AppMoodColors get moodColors => moodTheme.moodColors;
  AppMood get currentMood => moodTheme.mood;
}
