import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/reminders/reminder_model.dart';
import '../../../domain/reminders/reminder_provider.dart';
import '../../common/widgets/reusable_components.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Walk, 2: Jog, 3: Motorcycle

  String _getFilterType(int index) {
    switch (index) {
      case 1:
        return 'Walk';
      case 2:
        return 'Jog';
      case 3:
        return 'Motorcycle';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.moodColors;
    final reminderState = ref.watch(reminderProvider);

    final filterType = _getFilterType(_selectedFilterIndex);
    final filteredReminders = filterType == 'All'
        ? reminderState.reminders
        : reminderState.reminders.where((r) => r.activityType == filterType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Walk Reminders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Schedule reminders to maintain your movement streak and mood vibe.',
                style: TextStyle(
                  color: colors.mutedText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(0, 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip(1, 'Walking'),
                    const SizedBox(width: 8),
                    _buildFilterChip(2, 'Jogging'),
                    const SizedBox(width: 8),
                    _buildFilterChip(3, 'Motorcycle'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scheduled Cards List or Empty State
              Expanded(
                child: reminderState.isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.accent))
                    : filteredReminders.isEmpty
                        ? EmptyState(
                            icon: Icons.notifications_paused_outlined,
                            title: 'No Reminders Scheduled',
                            description:
                                'Set up walk reminders to keep yourself accountable and refreshed.',
                            buttonLabel: 'Create Reminder',
                            onButtonPressed: () => _showAddReminderDialog(context),
                          )
                        : ListView.builder(
                            itemCount: filteredReminders.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final item = filteredReminders[index];
                              return _buildReminderCard(item);
                            },
                          ),
              ),

              // Create Reminder Primary Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: PrimaryButton(
                  label: 'Create Walk Reminder',
                  icon: Icons.alarm_add_rounded,
                  onPressed: () => _showAddReminderDialog(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final colors = context.moodColors;
    final isSelected = _selectedFilterIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colors.accent
                : colors.mutedText.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (colors.isDark ? Colors.black : Colors.white)
                : colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel item) {
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.mutedText.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activityIcon, color: colors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.formattedTime} • ${item.formattedDate}',
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.accent2.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.activityType} • ${item.mood}',
                    style: TextStyle(
                      color: colors.accent2,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: item.isEnabled,
            activeTrackColor: colors.accent,
            onChanged: (val) {
              ref.read(reminderProvider.notifier).toggleReminder(item.id, val);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colors.mutedText, size: 20),
            onPressed: () {
              ref.read(reminderProvider.notifier).deleteReminder(item.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final colors = context.moodColors;
    final titleController = TextEditingController(text: 'Mindful Outdoor Stroll');
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String selectedActivity = 'Walk';
    String selectedMood = 'Quiet Reset';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Walk Reminder',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Title Input Field
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        labelText: 'Reminder Title',
                        labelStyle: TextStyle(color: colors.mutedText),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Date & Time Selectors Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(selectedTime.format(context)),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedTime = picked;
                                  selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Activity Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedActivity,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        labelText: 'Activity Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Walk', 'Jog', 'Motorcycle']
                          .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedActivity = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Mood Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedMood,
                      dropdownColor: colors.surface,
                      style: TextStyle(color: colors.text),
                      decoration: InputDecoration(
                        labelText: 'Mood Theme',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Neon Rain', 'Quiet Reset', 'Main Character Walk', 'Golden Hour Grind']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMood = val);
                      },
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      label: 'Schedule Reminder',
                      icon: Icons.alarm_on_rounded,
                      onPressed: () async {
                        // Request Android Notifications Permission
                        await ref.read(notificationServiceProvider).requestPermission();

                        final scheduledDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        await ref.read(reminderProvider.notifier).addReminder(
                              title: titleController.text.trim().isNotEmpty
                                  ? titleController.text.trim()
                                  : 'Outdoor Route Stroll',
                              scheduledAt: scheduledDateTime,
                              activityType: selectedActivity,
                              mood: selectedMood,
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Walk reminder scheduled successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
