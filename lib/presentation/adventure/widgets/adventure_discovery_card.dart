import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/adventure/adventure_provider.dart';
import '../../../domain/routing/route_provider.dart';
import '../../common/widgets/reusable_components.dart';

class AdventureDiscoveryCard extends ConsumerWidget {
  const AdventureDiscoveryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.moodColors;
    final adventureState = ref.watch(adventureProvider);
    final activePlace = adventureState.activePlace;

    return GlassSurfaceCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      borderColor: colors.accent.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.explore_rounded, color: colors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Adventure Discovery',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent2.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Real OSM Places',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryChip(context, ref, 'cafe', 'Cafes ☕'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, ref, 'park', 'Parks 🍃'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, ref, 'viewpoint', 'Scenic 🌄'),
                const SizedBox(width: 8),
                _buildCategoryChip(context, ref, 'restaurant', 'Food 🍽️'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Discovery Place Box
          if (adventureState.isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: CircularProgressIndicator(color: colors.accent),
              ),
            ),
          ] else if (activePlace != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_outlined, color: colors.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activePlace.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activePlace.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Controls Row
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Skip / Next Stop',
                    icon: Icons.skip_next_rounded,
                    onPressed: () {
                      ref.read(adventureProvider.notifier).skipToNextPlace();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Add Waypoint',
                    icon: Icons.add_location_alt_rounded,
                    onPressed: () {
                      final waypoint = LatLng(activePlace.latitude, activePlace.longitude);
                      ref.read(routeProvider.notifier).addWaypoint(waypoint);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added "${activePlace.title}" to route waypoints!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
              ),
              child: Text(
                'Tap a category above to discover real nearby food, park, or scenic stops.',
                style: TextStyle(color: colors.mutedText, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref,
    String categoryKey,
    String label,
  ) {
    final colors = context.moodColors;
    final activeCategory = ref.watch(adventureProvider).activeCategory;
    final isSelected = activeCategory == categoryKey;

    return GestureDetector(
      onTap: () {
        ref.read(adventureProvider.notifier).fetchDiscoveryPlaces(categoryKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : colors.mutedText.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (colors.isDark ? Colors.black : Colors.white)
                : colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
