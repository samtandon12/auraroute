import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/mood_provider.dart';
import '../../../core/theme/mood_tokens.dart';
import '../../../domain/ai/ai_provider.dart';
import 'reusable_components.dart';

class AiCompanionCard extends ConsumerWidget {
  final VoidCallback? onStartRoute;

  const AiCompanionCard({
    super.key,
    this.onStartRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodProvider);
    final colors = context.moodColors;
    final aiState = ref.watch(aiProvider);
    final rec = aiState.recommendation;

    return GlassSurfaceCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      borderColor: colors.accent.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: colors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'AI Companion • ${currentMood.displayName}',
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (rec != null && rec.isFallback)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Local Fallback',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(currentMood.vibeEmoji, style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 14),

          // Recommendation Body
          if (aiState.isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: colors.accent),
                    const SizedBox(height: 12),
                    Text(
                      'Crafting AI recommendation based on your mood & weather...',
                      style: TextStyle(color: colors.mutedText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (rec != null) ...[
            Text(
              rec.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              rec.recommendation,
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology_rounded, size: 18, color: colors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec.reason,
                      style: TextStyle(
                        color: colors.mutedText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Optional Challenges Dares Box
            if (rec.challenges.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Optional Walk Challenges',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              ...rec.challenges.map(
                (ch) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 14, color: colors.accent2),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ch,
                          style: TextStyle(color: colors.mutedText, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      ref.read(aiProvider.notifier).generateRecommendation();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Start Route',
                    icon: Icons.navigation_rounded,
                    onPressed: onStartRoute,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'AI-Powered Mood Route',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Generate a custom walk recommendation aligned with your current energy level and surroundings.',
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Generate AI Route',
              icon: Icons.auto_awesome,
              onPressed: () {
                ref.read(aiProvider.notifier).generateRecommendation();
              },
            ),
          ],
        ],
      ),
    );
  }
}
