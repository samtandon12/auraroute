import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/mood_provider.dart';
import '../../../core/theme/mood_tokens.dart';
import '../../../domain/favorites/favorites_model.dart';
import '../../../domain/favorites/favorites_provider.dart';
import '../../../domain/history/history_model.dart';
import '../../../domain/history/history_provider.dart';
import '../../common/widgets/reusable_components.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(moodProvider);
    final colors = context.moodColors;
    final historyState = ref.watch(historyProvider);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar & Bio Card
              GlassSurfaceCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar Placeholder
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accent.withValues(alpha: 0.2),
                        border: Border.all(color: colors.accent, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text('⚡', style: TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aura Explorer',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'explorer@auraroute.ai',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MoodChip(mood: currentMood),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Walk Statistics Overview (Derived strictly from SQLite history)
              const SectionHeader(title: 'Lifetime Stats'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.straighten_rounded,
                      value: historyState.formattedTotalDistance,
                      label: 'Distance',
                      accentColor: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.timer_outlined,
                      value: historyState.formattedTotalDuration,
                      label: 'Time Walked',
                      accentColor: colors.accent2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.emoji_events_outlined,
                      value: '${historyState.totalRoutesCompleted} Routes',
                      label: 'Completed',
                      accentColor: colors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completed Walk History Section
              const SectionHeader(
                title: 'Recent Walk History',
                subtitle: 'Your completed outdoor journeys',
              ),
              const SizedBox(height: 10),
              if (historyState.isLoading)
                Center(child: CircularProgressIndicator(color: colors.accent))
              else if (historyState.history.isEmpty)
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
                              'Complete a route session to log your walk history automatically.',
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
                )
              else
                Column(
                  children: historyState.history
                      .take(5)
                      .map((item) => _buildHistoryCard(context, item))
                      .toList(),
                ),

              const SizedBox(height: 24),

              // Saved Favorite Routes Section
              const SectionHeader(
                title: 'Saved Favorite Routes',
                subtitle: 'Bookmarked routes for quick access',
              ),
              const SizedBox(height: 10),
              if (favoritesState.isLoading)
                Center(child: CircularProgressIndicator(color: colors.accent))
              else if (favoritesState.favorites.isEmpty)
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
                        child: Icon(Icons.bookmark_border_rounded, color: colors.accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No favorite routes saved',
                              style: TextStyle(
                                color: colors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bookmark your favorite destinations on the map for 1-tap navigation.',
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
                )
              else
                Column(
                  children: favoritesState.favorites
                      .map((item) => _buildFavoriteCard(context, ref, item))
                      .toList(),
                ),

              const SizedBox(height: 24),

              // Settings Options List
              const SectionHeader(title: 'Settings'),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: Icons.palette_outlined,
                title: 'Current Vibe Theme',
                subtitle: currentMood.displayName,
                trailing: Text(
                  currentMood.vibeEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
                onTap: () {
                  ref.read(moodProvider.notifier).setRandomMood();
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.straighten_rounded,
                title: 'Distance Units',
                subtitle: 'Kilometers (km)',
                trailing: Icon(Icons.swap_horiz_rounded, color: colors.mutedText),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unit preferences saved'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_none_rounded,
                title: 'Notifications & Reminders',
                subtitle: 'Walk reminders enabled',
                trailing: Icon(Icons.chevron_right_rounded, color: colors.mutedText),
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & GPS Permissions',
                subtitle: 'Foreground location access',
                trailing: Icon(Icons.chevron_right_rounded, color: colors.mutedText),
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'About AuraRoute',
                subtitle: 'Version 1.0.0 • AI-Powered Routes',
                trailing: Icon(Icons.chevron_right_rounded, color: colors.mutedText),
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    WidgetRef ref,
    FavoriteRouteModel item,
  ) {
    final colors = context.moodColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.bookmark_rounded, color: colors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.destinationName} • ${item.formattedDistance} • ${item.mood}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colors.mutedText, size: 20),
            onPressed: () {
              ref.read(favoritesProvider.notifier).removeFavorite(item.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WalkHistoryItem item) {
    final colors = context.moodColors;

    IconData activityIcon;
    switch (item.activityType) {
      case 'Jog':
        activityIcon = Icons.directions_run_rounded;
        break;
      case 'Motorcycle':
        activityIcon = Icons.two_wheeler_rounded;
        break;
      default:
        activityIcon = Icons.directions_walk_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activityIcon, color: colors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.formattedDistance} • ${item.formattedDuration} • ${item.formattedDate}',
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.accent2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.mood,
              style: TextStyle(
                color: colors.accent2,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colors = context.moodColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.mutedText.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.accent, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colors.mutedText,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colors = context.moodColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.route_rounded, color: colors.accent),
            ),
            const SizedBox(width: 12),
            Text(
              'AuraRoute',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                color: colors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI-Powered Mood Route Generator & Walk Companion',
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'AuraRoute combines mood intent, real place data, weather insights, and adaptive routing to craft personalized urban journeys.',
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '• Design tokens: 4 Mood Themes\n'
              '• Persistence: Local SQLite Database\n'
              '• Notifications: flutter_local_notifications',
              style: TextStyle(
                color: colors.accent2,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.accent)),
          ),
        ],
      ),
    );
  }
}
