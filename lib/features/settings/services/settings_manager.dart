import 'package:deardiary/features/settings/models/settings_model.dart';
import 'package:deardiary/features/settings/repository/settings_repository.dart';
import 'package:flutter/material.dart';

class SettingsManager with ChangeNotifier {
  final SettingsRepository _repository;

  SettingsModel? _settings; // Nullable hale getirildi

  SettingsManager(this._repository);

  SettingsModel? get settings => _settings;

  bool get skipMoodSelection => _settings?.skipMoodSelection ?? false;
  bool get showMoodInCalendar => _settings?.showMoodInCalendar ?? false;

  // Haftanın ilk günü getter'ı eklendi
  String? get firstDayOfWeek => _settings?.firstDayOfWeek;
  String? get theme => _settings?.theme;
  // Bildirim ayarları için getter'lar
  bool get dailyReminderEnabled => _settings?.dailyReminderEnabled ?? false;
  bool get pinnedNotificationEnabled => _settings?.pinnedNotificationEnabled ?? false;
  
  TimeOfDay get reminderTime {
    final timeParts = (_settings?.reminderTime ?? "08:00").split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }
  String get reminderSentence => _settings?.reminderSentence ?? "Bugünkü notunuzu yazmayı unutmayın!";

  Future<void> loadSettings() async {
    try {
      _settings = await _repository.fetchSettings();
      notifyListeners(); // Dinleyicilere değişikliği bildir
    } catch (e) {
      // Hata yönetimi yapılabilir
      debugPrint('Settings yüklenirken hata oluştu: $e');
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    if (_settings == null) {
      throw Exception('Ayarlar henüz yüklenmedi. Lütfen loadSettings() çağırın.');
    }

    // Ayarları güncelle
    switch (key) {
      case 'skipMoodSelection':
        _settings!.skipMoodSelection = value;
        break;
      case 'showMoodInCalendar':
        _settings!.showMoodInCalendar = value;
        break;
      case 'firstDayOfWeek':
        _settings!.firstDayOfWeek = value;
        break;
      case 'dateFormat':
        _settings!.dateFormat = value;
        break;
      case 'timeFormat':
        _settings!.timeFormat = value;
        break;
      case 'theme':
        _settings!.theme = value;
        break;
      case 'dailyReminderEnabled':
        _settings!.dailyReminderEnabled = value;
        break;
      case 'pinnedNotificationEnabled':
        _settings!.pinnedNotificationEnabled = value;
        break;
      case 'reminderTime':
        _settings!.reminderTime = value;
        break;
      case 'reminderSentence':
        _settings!.reminderSentence = value;
        break;
          
      default:
        throw Exception('Invalid setting key: $key');
    }

    try {
      // Ayarları kaydet
      await _repository.saveSettings(_settings!);
      notifyListeners(); // Dinleyicilere değişikliği bildir
    } catch (e) {
      // Hata yönetimi
      debugPrint('Ayarlar kaydedilirken hata oluştu: $e');
    }
  }
}