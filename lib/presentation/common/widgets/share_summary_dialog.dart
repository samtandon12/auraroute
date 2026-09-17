import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/routing/route_model.dart';
import 'reusable_components.dart';

class ShareSummaryDialog extends StatelessWidget {
  final double distanceMeters;
  final double durationSeconds;
  final String mood;
  final String destinationName;

  const ShareSummaryDialog({
    super.key,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.mood,
    required this.destinationName,
  });

  String get _shareText {
    final distStr = RouteResult.formatDistance(distanceMeters);
    final durStr = RouteResult.formatDuration(durationSeconds);
    return '🚶 Finished a $mood walk to $destinationName ($distStr • $durStr) with #AuraRoute! ✨';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moodColors;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassSurfaceCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(22),
        borderColor: colors.accent.withValues(alpha: 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share_rounded, color: colors.accent, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Share Walk Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
              ),
              child: Text(
                _shareText,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.security_rounded, size: 14, color: colors.mutedText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Privacy-safe: Exact start/home coordinates are never included in shareable text.',
                    style: TextStyle(
                      color: colors.mutedText,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Copy to Clipboard',
                    icon: Icons.copy_rounded,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _shareText));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Walk summary copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
