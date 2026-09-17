import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/mood_provider.dart';
import '../../../core/theme/mood_tokens.dart';
import '../../common/widgets/reusable_components.dart';

class MoodSelectionScreen extends ConsumerWidget {
  const MoodSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodProvider);
    final moodNotifier = ref.read(moodProvider.notifier);
    final colors = context.moodColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Vibe'),
        actions: [
          IconButton(
            tooltip: 'Surprise me',
            icon: const Icon(Icons.casino_outlined),
            onPressed: () => moodNotifier.setRandomMood(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Select your vibe',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a mood to adapt your entire route experience and color theme.',
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Cards List
              Expanded(
                child: ListView.builder(
                  itemCount: AppMood.values.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final mood = AppMood.values[index];
                    final isSelected = mood == currentMood;

                    return MoodCard(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () => moodNotifier.setMood(mood),
                    );
                  },
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SecondaryButton(
                  label: 'Surprise Me (Random Vibe)',
                  icon: Icons.shuffle_rounded,
                  onPressed: () => moodNotifier.setRandomMood(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
