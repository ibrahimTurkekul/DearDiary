import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:flutter/foundation.dart'; // defaultTargetPlatform için
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstDayOfWeekPopup extends StatefulWidget {
  const FirstDayOfWeekPopup({super.key});

  @override
  State<FirstDayOfWeekPopup> createState() => _FirstDayOfWeekPopupState();
}

class _FirstDayOfWeekPopupState extends State<FirstDayOfWeekPopup> {
  final List<String> days = ['Otomatik', 'Pazar', 'Pazartesi', 'Cumartesi'];
  late String selectedDay;

  @override
  void initState() {
    super.initState();
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);

    // Varsayılan olarak "Otomatik" seçili ve cihazın sistem hafta başlangıç günü alınacak
    selectedDay = settingsManager.firstDayOfWeek ?? days[0]; // Varsayılan olarak "Otomatik"
  }

  /// Cihazın sistem takviminin ilk gününü belirle
  String _getSystemFirstDayOfWeek() {
    // Web, mobil ve masaüstü platformları için uygun kontrol
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return 'Pazar'; // Android ve iOS için varsayılan
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return 'Pazartesi'; // Masaüstü için varsayılan
      case TargetPlatform.fuchsia:
        return 'Pazartesi'; // Fuchsia için varsayılan
      default:
        return 'Pazartesi'; // Web için varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sistem varsayılanı seçilmişse cihazın hafta başlangıç gününü gösterim için belirle
    final systemFirstDay = _getSystemFirstDayOfWeek();

    return AlertDialog(
      title: const Text('Haftanın İlk Günü'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return RadioListTile<String>(
              title: Text(day == 'Otomatik' ? '$day ($systemFirstDay)' : day),
              value: day,
              groupValue: selectedDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDay = value;
                  });
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Popup'ı kapat
          },
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            // Seçimi kaydet ve ayarlarda güncelle
            final settingsManager = Provider.of<SettingsManager>(context, listen: false);

            // Eğer "Otomatik" seçiliyse "Otomatik" olarak kaydediyoruz
            settingsManager.updateSetting('firstDayOfWeek', selectedDay);

            Navigator.of(context).pop(); // Popup'ı kapat
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}