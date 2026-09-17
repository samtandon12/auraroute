import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/mood_provider.dart';
import 'presentation/navigation_map/screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AuraRouteApp(),
    ),
  );
}

class AuraRouteApp extends ConsumerWidget {
  const AuraRouteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodProvider);

    return MaterialApp(
      title: 'AuraRoute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(currentMood),
      home: const AppShell(),
    );
  }
}
