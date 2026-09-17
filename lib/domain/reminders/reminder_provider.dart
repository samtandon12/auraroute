import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import 'reminder_model.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class ReminderState {
  final bool isLoading;
  final List<ReminderModel> reminders;
  final String? errorMessage;

  const ReminderState({
    this.isLoading = false,
    this.reminders = const [],
    this.errorMessage,
  });

  ReminderState copyWith({
    bool? isLoading,
    List<ReminderModel>? reminders,
    String? errorMessage,
  }) {
    return ReminderState(
      isLoading: isLoading ?? this.isLoading,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReminderNotifier extends Notifier<ReminderState> {
  @override
  ReminderState build() {
    Future.microtask(() => loadReminders());
    return const ReminderState(isLoading: true);
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = ref.read(databaseServiceProvider);
      final rows = await db.getReminders();
      final reminders = rows.map((r) => ReminderModel.fromMap(r)).toList();
      state = state.copyWith(isLoading: false, reminders: reminders);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reminders: $e',
      );
    }
  }

  Future<void> addReminder({
    required String title,
    required DateTime scheduledAt,
    required String activityType,
    required String mood,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notificationId = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000;

    final reminder = ReminderModel(
      id: id,
      title: title,
      scheduledAt: scheduledAt,
      activityType: activityType,
      mood: mood,
      isEnabled: true,
      notificationId: notificationId,
    );

    try {
      final db = ref.read(databaseServiceProvider);
      await db.insertReminder(reminder.toMap());

      final notifications = ref.read(notificationServiceProvider);
      await notifications.scheduleNotification(
        id: notificationId,
        title: 'AuraRoute Reminder: $title',
        body: 'Time for your $mood $activityType! Ready to explore?',
        scheduledDate: scheduledAt,
      );

      await loadReminders();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not create reminder: $e');
    }
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    try {
      final db = ref.read(databaseServiceProvider);
      await db.updateReminderStatus(id, isEnabled);

      final reminder = state.reminders.firstWhere((r) => r.id == id);
      final notifications = ref.read(notificationServiceProvider);

      if (isEnabled) {
        await notifications.scheduleNotification(
          id: reminder.notificationId,
          title: 'AuraRoute Reminder: ${reminder.title}',
          body: 'Time for your ${reminder.mood} ${reminder.activityType}!',
          scheduledDate: reminder.scheduledAt,
        );
      } else {
        await notifications.cancelNotification(reminder.notificationId);
      }

      await loadReminders();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not toggle reminder: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final reminder = state.reminders.firstWhere((r) => r.id == id);
      final db = ref.read(databaseServiceProvider);
      await db.deleteReminder(id);

      final notifications = ref.read(notificationServiceProvider);
      await notifications.cancelNotification(reminder.notificationId);

      await loadReminders();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not delete reminder: $e');
    }
  }
}

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderState>(() {
  return ReminderNotifier();
});
