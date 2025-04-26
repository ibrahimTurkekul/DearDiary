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

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Android 13 ve üzeri için bildirim izinlerini kontrol edin
    if (await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false) {
      debugPrint("Bildirimler açık");
    } else {
      debugPrint("Bildirim izni alınmamış. Lütfen izin isteyin.");
    }

    tz.initializeTimeZones();
  }

  

  Future<void> showDailyReminderNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

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
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
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
    NotificationDetails(
      android: AndroidNotificationDetails(
        'pinned_channel',
        'Pinned Notification',
        channelDescription: 'This channel is used for pinned notifications',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true, // Sabit bildirim için
        actions: [
          AndroidNotificationAction(
            'add_entry_action', // Günlük ekleme eylemi
            'Günlük Ekle',
          ),
          AndroidNotificationAction(
            'settings_action', // Ayarlar eylemi
            'Ayarlar',
          ),
        ],
      ),
    ),
  );
}

// Bildirim eylemlerini dinlemek için
void handleNotificationAction(String actionId, Null Function() param1) {
  if (actionId == 'add_entry_action') {
    // Günlük ekleme sayfasına yönlendirin
    // Örneğin, bir callback ile çağırabilirsiniz
  } else if (actionId == 'settings_action') {
    // Bildirim ayarları sayfasına yönlendirin
  }
}

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}

