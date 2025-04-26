import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için gerekli
import 'package:provider/provider.dart';

class DateFormatPopup extends StatefulWidget {
  const DateFormatPopup({super.key});

  @override
  State<DateFormatPopup> createState() => _DateFormatPopupState();
}

class _DateFormatPopupState extends State<DateFormatPopup> {
  final List<String> formats = ['dd-MMM-yyyy', 'dd-MMM-yyyy HH:mm', 'dd-MMM-yyyy EEEE HH:mm'];
  late String selectedFormat;

  @override
  void initState() {
    super.initState();
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    selectedFormat = settingsManager.settings?.dateFormat ?? formats[0]; // Varsayılan format
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return AlertDialog(
      title: const Text('Tarih Biçimi'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: formats.length,
          itemBuilder: (context, index) {
            final format = formats[index];
            final formattedDate = DateFormat(format).format(now);

            return RadioListTile<String>(
              title: Text(formattedDate), // Tarihi formatlanmış şekilde göster
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
            settingsManager.updateSetting('dateFormat', selectedFormat); // Formatı kaydet
            Navigator.of(context).pop(); // Popup'ı kapat
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}