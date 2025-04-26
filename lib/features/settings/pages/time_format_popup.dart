import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeFormatPopup extends StatefulWidget {
  const TimeFormatPopup({super.key});

  @override
  State<TimeFormatPopup> createState() => _TimeFormatPopupState();
}

class _TimeFormatPopupState extends State<TimeFormatPopup> {
  final List<String> formats = ['System Default', '24-hour', '12-hour'];
  late String selectedFormat;

  @override
  void initState() {
    super.initState();
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    selectedFormat = settingsManager.settings?.timeFormat ?? formats[0]; // Varsayılan format
  }

  @override
  Widget build(BuildContext context) {
    // Sistem varsayılanı seçilmişse cihazın saat formatını gösterim için belirle
    final is24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final systemDefaultFormat = is24HourFormat ? '24-hour' : '12-hour';

    return AlertDialog(
      title: const Text('Zaman Formatı'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: formats.length,
          itemBuilder: (context, index) {
            final format = formats[index];
            return RadioListTile<String>(
              title: Text(format == 'System Default' ? '$format ($systemDefaultFormat)' : format),
              value: format,
              groupValue: selectedFormat,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFormat = value;
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
            final settingsManager = Provider.of<SettingsManager>(context, listen: false);

            // Ayarları kaydet
            settingsManager.updateSetting('timeFormat', selectedFormat);

            Navigator.of(context).pop(); // Popup'ı kapat
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}