import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/mood_provider.dart';
import '../../../core/theme/mood_tokens.dart';
import '../../common/widgets/ai_companion_card.dart';
import '../../common/widgets/reusable_components.dart';
import '../../common/widgets/weather_chip.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodProvider);
    final colors = context.moodColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Greeting & Weather Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ready to explore?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                            ),
                      ),
                    ],
                  ),
                  const WeatherChip(),
                ],
              ),
              const SizedBox(height: 20),

              // Hero AI Companion Card with Primary CTA
              AiCompanionCard(
                onStartRoute: () => onNavigateToTab?.call(1),
              ),
              const SizedBox(height: 24),

              // Quick Stats Grid
              const SectionHeader(title: 'Overview'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.directions_walk_rounded,
                      value: '14.8 km',
                      label: 'Total Distance',
                      accentColor: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.map_outlined,
                      value: '8 Walks',
                      label: 'Completed',
                      accentColor: colors.accent2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.local_fire_department_rounded,
                      value: '4 Days',
                      label: 'Active Streak',
                      accentColor: colors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Suggested Activities Section
              SectionHeader(
                title: 'Suggested Walks',
                subtitle: 'Curated for ${currentMood.displayName}',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSuggestedCard(
                      context,
                      title: 'Mindful Stroll',
                      duration: '25 min • 1.8 km',
                      vibeTag: 'Restorative',
                      icon: Icons.self_improvement_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildSuggestedCard(
                      context,
                      title: 'Scenic Discovery',
                      duration: '40 min • 3.2 km',
                      vibeTag: 'Exploration',
                      icon: Icons.nature_people_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildSuggestedCard(
                      context,
                      title: 'Power Grind Jog',
                      duration: '20 min • 2.5 km',
                      vibeTag: 'High Energy',
                      icon: Icons.bolt_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Routes Section
              const SectionHeader(
                title: 'Recent Routes',
                subtitle: 'Your recent walk history',
              ),
              const SizedBox(height: 10),

              // Clean Empty / Starter state card
              GlassSurfaceCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.history_toggle_off_rounded, color: colors.accent),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No recent walks saved yet',
                            style: TextStyle(
                              color: colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Completed walks will appear here automatically.',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedCard(
    BuildContext context, {
    required String title,
    required String duration,
    required String vibeTag,
    required IconData icon,
  }) {
    final colors = context.moodColors;

    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.mutedText.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: colors.accent),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent2.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  vibeTag,
                  style: TextStyle(
                    color: colors.accent2,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
