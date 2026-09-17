import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings: initSettings);

    // Create Android Notification Channel
    const androidChannel = AndroidNotificationChannel(
      'auraroute_reminders',
      'Walk Reminders',
      description: 'Scheduled reminders for your mood walks and jogs',
      importance: Importance.high,
    );

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
    }

    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await initialize();

    // Ensure scheduled date is in the future
    if (scheduledDate.isBefore(DateTime.now())) return;

    const androidDetails = AndroidNotificationDetails(
      'auraroute_reminders',
      'Walk Reminders',
      channelDescription: 'Scheduled reminders for your mood walks and jogs',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    // Show immediate notification if scheduled within 5 seconds, or schedule
    final difference = scheduledDate.difference(DateTime.now());
    if (difference.inSeconds <= 5) {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } else {
      // Show notification when timer fires
      Future.delayed(difference, () async {
        await _notificationsPlugin.show(
          id: id,
          title: title,
          body: body,
          notificationDetails: notificationDetails,
        );
      });
    }
  }

  Future<void> cancelNotification(int id) async {
    await initialize();
    await _notificationsPlugin.cancel(id: id);
  }
}
