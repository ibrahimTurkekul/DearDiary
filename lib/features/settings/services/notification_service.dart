import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        // Bildirim eylemleri burada ele alınabilir
        handleNotificationAction(response.actionId);
      },
    );

    tz.initializeTimeZones();

    // Bildirim izinlerini kontrol et
    if (!await _checkNotificationPermission()) {
      debugPrint("Bildirim izni alınmamış. Kullanıcıdan izin isteyin.");
    }
  }

  Future<bool> _checkNotificationPermission() async {
    final implementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    return await implementation?.areNotificationsEnabled() ?? false;
  }

  Future<void> requestNotificationPermission() async {
    final implementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (implementation != null) {
      await implementation
          .requestNotificationsPermission(); // Android 13+ için izin
    }
  }

  Future<void> showDailyReminderNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    debugPrint("Bildirim zamanlandı: $scheduledDate"); // Hata ayıklama için

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'This channel is used for daily reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Günlük aynı saatte bildirim
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    // Zaman hesaplama işlemi düzeltildi
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showPinnedNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pinned_channel',
          'Pinned Notification',
          channelDescription: 'This channel is used for pinned notifications',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true, // Sabit bildirim için
          autoCancel: false, // Kullanıcı tarafından kapatılamaz
        ),
      ),
    );
  }

  void handleNotificationAction(String? actionId) {
    if (actionId == 'add_entry_action') {
      debugPrint('Günlük ekleme eylemi seçildi.');
      // Günlük ekleme ekranına yönlendirme
    } else if (actionId == 'settings_action') {
      debugPrint('Ayarlar eylemi seçildi.');
      // Ayarlar ekranına yönlendirme
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
