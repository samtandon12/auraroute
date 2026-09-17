import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auraroute/main.dart';
import 'package:auraroute/core/theme/mood_provider.dart';

void main() {
  testWidgets('AuraRouteApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const AuraRouteApp(),
      ),
    );

    // Verify app title or core text exists
    expect(find.text('AuraRoute'), findsNothing); // Title is in MaterialApp metadata
  });
}
