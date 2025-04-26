import 'package:android_intent_plus/android_intent.dart';
import 'package:deardiary/features/settings/services/notification_service.dart';
import 'package:deardiary/features/settings/widgets/switch_item.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late bool _dailyReminderEnabled;
  late bool _pinnedNotificationEnabled;
  late TimeOfDay _reminderTime;
  late String _reminderSentence;

Future<void> requestExactAlarmPermission() async {
  final intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
  );
  await intent.launch();
}

  @override
  void initState() {
    super.initState();
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);

    // Ayarları yükle
    _dailyReminderEnabled = settingsManager.dailyReminderEnabled;
    _pinnedNotificationEnabled = settingsManager.pinnedNotificationEnabled; // SettingsManager'dan çekildi
    _reminderTime = settingsManager.reminderTime;
    _reminderSentence = settingsManager.reminderSentence;

    
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchItem(
              title: 'Günlük Hatırlatıcı',
              subtitle: 'Günlük hatırlatıcı bildirimlerini aç/kapat',
              value: _dailyReminderEnabled,
              onChanged: (value) {
                setState(() {
                  _dailyReminderEnabled = value;
                });

                // Ayarı kaydet
                settingsManager.updateSetting('dailyReminderEnabled', value);

                if (value) {
                  notificationService.showDailyReminderNotification(
                    id: 1,
                    title: 'Hatırlatıcı',
                    body: _reminderSentence,
                    time: _reminderTime,
                  );
                } else {
                  notificationService.cancelNotification(1);
                }
              },
            ),
            SwitchItem(
              title: 'Hatırlatıcıyı Bildirim Çubuğuna Sabitle',
              value: _pinnedNotificationEnabled,
              onChanged: (value) {
                setState(() {
                  _pinnedNotificationEnabled = value;
                });

                // Ayarı kaydet
                settingsManager.updateSetting('pinnedNotificationEnabled', value);

                if (value) {
                  notificationService.showPinnedNotification(
                    id: 2,
                    title: 'Sabit Hatırlatıcı',
                    body: _reminderSentence,
                  );
                  notificationService.handleNotificationAction('add_entry_action', () {
                    NavigationService().navigateToAddEntry();
                  });

                  notificationService.handleNotificationAction('settings_action', () {
                    NavigationService().navigateTo('/notifications');
                  });
                } else {
                  notificationService.cancelNotification(2);
                }
              },
            ),
            ListTile(
              title: const Text("Hatırlatma Zamanı"),
              subtitle: Text("Seçili Zaman: ${_reminderTime.format(context)}"),
              onTap: () => showTimePicker(
                context: context,
                initialTime: _reminderTime,
              ).then((value) {
                if (value != null) {
                  setState(() {
                    _reminderTime = value;
                  });

                  // Ayarı kaydet
                  settingsManager.updateSetting('reminderTime', '${value.hour}:${value.minute}');
 
                  if (_dailyReminderEnabled) {
                    notificationService.showDailyReminderNotification(
                      id: 1,
                      title: 'Hatırlatıcı',
                      body: _reminderSentence,
                      time: _reminderTime,
                    );
                  }
                }
              }),
            ),
            ListTile(
              title: const Text("Hatırlatma Cümlesi"),
              subtitle: Text(_reminderSentence),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController(text: _reminderSentence);

                    return AlertDialog(
                      title: const Text("Hatırlatma Cümlesini Düzenle"),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(hintText: "Bugünkü notunuzu yazmayı unutmayın!"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _reminderSentence = controller.text;
                            });

                            // Ayarı kaydet
                            settingsManager.updateSetting('reminderSentence', _reminderSentence);

                            if (_dailyReminderEnabled) {
                              notificationService.showDailyReminderNotification(
                                id: 1,
                                title: 'Hatırlatıcı',
                                body: _reminderSentence,
                                time: _reminderTime,
                              );
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text("Kaydet"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              title: const Text("Tam Zamanlı Alarm İzni İste"),
              subtitle: const Text("Tam zamanlı alarm izni istemek için tıklayın."),
              onTap: () async {
                await requestExactAlarmPermission();
              },
            ),
          ],
        ),
      ),
    );
  }
}
