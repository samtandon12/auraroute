import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/weather/weather_provider.dart';
import 'reusable_components.dart';

class WeatherChip extends ConsumerWidget {
  const WeatherChip({super.key});

  void _showWeatherDetails(BuildContext context, WidgetRef ref) {
    final weatherState = ref.read(weatherProvider);
    final weather = weatherState.weather;
    final colors = context.moodColors;

    if (weather == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: GlassSurfaceCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              borderColor: colors.accent.withValues(alpha: 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: weather.iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(weather.iconData, color: weather.iconColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.formattedTemperature,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              weather.conditionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.mutedText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: weather.isOutdoorFriendly
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          weather.isOutdoorFriendly ? 'Outdoor Friendly' : 'Caution',
                          style: TextStyle(
                            color: weather.isOutdoorFriendly ? Colors.green : Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailMetric(
                        context,
                        label: 'Feels Like',
                        value: '${weather.apparentTemperatureCelsius.round()}°C',
                        icon: Icons.thermostat_rounded,
                      ),
                      _buildDetailMetric(
                        context,
                        label: 'Wind Speed',
                        value: '${weather.windSpeedKmh.toStringAsFixed(1)} km/h',
                        icon: Icons.air_rounded,
                      ),
                      _buildDetailMetric(
                        context,
                        label: 'Rain',
                        value: '${weather.rainMm.toStringAsFixed(1)} mm',
                        icon: Icons.water_drop_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Close Weather Details',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailMetric(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final colors = context.moodColors;
    final weather = weatherState.weather;

    return GestureDetector(
      onTap: () => _showWeatherDetails(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.mutedText.withValues(alpha: 0.2),
          ),
        ),
        child: weatherState.isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    weather?.iconData ?? Icons.wb_sunny_rounded,
                    size: 15,
                    color: weather?.iconColor ?? Colors.amber,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      weather != null
                          ? '${weather.formattedTemperature} • ${weather.conditionLabel}'
                          : '22°C • Open-Meteo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
