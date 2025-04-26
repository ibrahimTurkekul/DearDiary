import 'package:deardiary/features/settings/models/settings_model.dart';
import 'package:deardiary/features/settings/repository/local_storage_provider.dart';
import 'package:deardiary/features/settings/repository/cloud_storage_provider.dart';

class SettingsRepository {
  final LocalStorageProvider _localStorageProvider = LocalStorageProvider();
  final CloudStorageProvider _cloudStorageProvider = CloudStorageProvider();

  Future<SettingsModel> fetchSettings() async {
    try {
      // Öncelikle yerel depodan ayarları oku
      final localSettings = await _localStorageProvider.readSettings();
      if (localSettings != null) {
        return localSettings;
      }

      // Yerel depoda ayar yoksa, bulut depodan ayarları al
      final cloudSettings = await _cloudStorageProvider.fetchSettings();
      if (cloudSettings != null) {
        // Buluttan alınan ayarları yerel depoya kaydet
        await _localStorageProvider.writeSettings(cloudSettings);
        return cloudSettings;
      }

      // Eğer ayar bulunamazsa, varsayılan ayarları döndür
      return SettingsModel(
        skipMoodSelection: false,
        showMoodInCalendar: false,
        firstDayOfWeek: 'Monday',
        dateFormat: 'dd-MM-yyyy',
        timeFormat: '24-hour',
        theme: 'Light',
      );
    } catch (e) {
      throw Exception('Ayarlar yüklenirken hata oluştu: $e');
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    try {
      // Ayarları hem yerel hem de bulut depoya kaydet
      await _localStorageProvider.writeSettings(settings);
      await _cloudStorageProvider.saveSettings(settings);
    } catch (e) {
      throw Exception('Ayarlar kaydedilirken hata oluştu: $e');
    }
  }
}