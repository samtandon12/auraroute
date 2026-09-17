import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/history/history_provider.dart';
import '../../../domain/routing/route_model.dart';
import 'reusable_components.dart';

class RouteCompletionDialog extends ConsumerWidget {
  final double distanceMeters;
  final double durationSeconds;
  final String activityType;
  final String mood;
  final String destinationName;
  final VoidCallback onDismissed;

  const RouteCompletionDialog({
    super.key,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.activityType,
    required this.mood,
    required this.destinationName,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.moodColors;
    final formattedDist = RouteResult.formatDistance(distanceMeters);
    final formattedDur = RouteResult.formatDuration(durationSeconds);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: GlassSurfaceCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          borderColor: colors.accent.withValues(alpha: 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Celebration Badge Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Text('🎉', style: TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 16),
            Text(
              'Route Completed!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Awesome work completing your $mood $activityType to $destinationName.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Route Metrics Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat(
                  context,
                  label: 'Distance',
                  value: formattedDist,
                  icon: Icons.straighten_rounded,
                ),
                _buildSummaryStat(
                  context,
                  label: 'Duration',
                  value: formattedDur,
                  icon: Icons.timer_outlined,
                ),
                _buildSummaryStat(
                  context,
                  label: 'Mood',
                  value: mood,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save to History CTA Button
            PrimaryButton(
              label: 'Save to Walk History',
              icon: Icons.check_circle_rounded,
              onPressed: () async {
                await ref.read(historyProvider.notifier).saveCompletedWalk(
                      distanceMeters: distanceMeters,
                      durationSeconds: durationSeconds,
                      activityType: activityType,
                      mood: mood,
                      destinationName: destinationName,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  onDismissed();
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildSummaryStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = context.moodColors;
    return Column(
      children: [
        Icon(icon, size: 20, color: colors.accent),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: colors.mutedText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
