import 'package:deardiary/features/settings/pages/date_format_popup.dart';
import 'package:deardiary/features/settings/pages/first_day_of_week_popup.dart';
import 'package:deardiary/features/settings/pages/time_format_popup.dart';
import 'package:flutter/material.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // `loadSettings` çağrısı, `FutureBuilder` ile asenkron olarak beklenir.
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);

    return FutureBuilder(
      future: settingsManager.loadSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Yükleme göstergesi
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Hata durumu
          return Scaffold(
            body: Center(
              child: Text('Hata oluştu: ${snapshot.error}'),
            ),
          );
        }

        // Yükleme tamamlandıktan sonra ayar arayüzünü göster
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ayarlar'),
          ),
          body: ListView(
            children: [
              // Genel Grup
              const SettingsGroupTitle(title: 'Genel'),
              SettingsMenuItem(
                title: 'Ruh Hali Tarzı',
                icon: Icons.mood,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/moodStyle'),
              ),
              SettingsMenuItem(
                title: 'Günlük Kilidi',
                icon: Icons.lock,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/dailyLock'),
              ),
              SettingsMenuItem(
                title: 'Yedekleme Seçenekleri',
                icon: Icons.backup,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/backupOptions'),
              ),
              SettingsMenuItem(
                title: 'Temalar',
                icon: Icons.color_lens,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/theme'),
              ),
              SettingsMenuItem(
                title: 'Widget',
                icon: Icons.widgets,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/widgetSettings'),
              ),
              SettingsMenuItem(
                title: 'Bildirim',
                icon: Icons.notifications,
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => NavigationService().navigateTo('/notifications'),
              ),
              const Divider(),

              // Günlük Tercihleri Grup
              const SettingsGroupTitle(title: 'Günlük Tercihleri'),
              Consumer<SettingsManager>(
                builder: (context, settingsManager, child) {
                  return SettingsSwitchItem(
                    title: 'Ruh Hali Seçimini Atla',
                    value: settingsManager.skipMoodSelection,
                    onChanged: (value) {
                      settingsManager.updateSetting('skipMoodSelection', value);
                    },
                  );
                },
              ),
              Consumer<SettingsManager>(
                builder: (context, settingsManager, child) {
                  return SettingsSwitchItem(
                    title: 'Takvimde Ruh Halini Göster',
                    value: settingsManager.showMoodInCalendar,
                    onChanged: (value) {
                      settingsManager.updateSetting('showMoodInCalendar', value);
                    },
                  );
                },
              ),
              const Divider(),

              // Zaman Seçenekleri Grup
              const SettingsGroupTitle(title: 'Zaman Seçenekleri'),
              SettingsMenuItem(
                title: 'Haftanın ilk günü',
                icon: Icons.calendar_today,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Popup dışında tıklayarak kapatmayı engelle
                    barrierColor: Colors.black.withOpacity(0.5), // Arkadaki ekranı sönük göster
                    builder: (context) => const FirstDayOfWeekPopup(),
                  );
                },
              ),
              SettingsMenuItem(
                title: 'Günlük Tarih Biçimi',
                icon: Icons.date_range,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Popup dışında tıklayarak kapatmayı engelle
                    barrierColor: Colors.black.withOpacity(0.5), // Arkadaki ekranı sönük göster
                    builder: (context) => const DateFormatPopup(),
                  );
                },
              ),
              SettingsMenuItem(
                title: 'Zaman Formatı',
                icon: Icons.access_time,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Popup dışında tıklayarak kapatmayı engelle
                    barrierColor: Colors.black.withOpacity(0.5), // Arkadaki ekranı sönük göster
                    builder: (context) => const TimeFormatPopup(),
                  );
                }
              ),
              const Divider(),

              // Hakkında Grup
              const SettingsGroupTitle(title: 'Hakkında'),
              SettingsMenuItem(
                title: 'Gizlilik Politikası',
                icon: Icons.privacy_tip,
                onTap: () => NavigationService().navigateTo('/privacyPolicy'),
              ),
              SettingsMenuItem(
                title: 'Bizi değerlendirin',
                icon: Icons.star_rate,
                onTap: () => NavigationService().navigateTo('/rateUs'),
              ),
              SettingsMenuItem(
                title: 'Geri Bildirim',
                icon: Icons.feedback,
                onTap: () => NavigationService().navigateTo('/feedback'),
              ),
              SettingsMenuItem(
                title: 'Dil Seçenekleri',
                icon: Icons.language,
                onTap: () => NavigationService().navigateTo('/languageOptions'),
              ),
              SettingsMenuItem(
                title: 'Bağış Yap',
                icon: Icons.volunteer_activism,
                onTap: () => NavigationService().navigateTo('/donation'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsGroupTitle extends StatelessWidget {
  final String title;

  const SettingsGroupTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing; // Opsiyonel trailing widget

  const SettingsMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing, // trailing parametresi isteğe bağlı
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class SettingsSwitchItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}