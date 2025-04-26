import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deardiary/features/settings/models/settings_model.dart';

class LocalStorageProvider {
  static const String _settingsKey = 'app_settings';

  Future<SettingsModel?> readSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      return SettingsModel.fromJson(jsonDecode(settingsJson));
    }
    return null;
  }

  Future<void> writeSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }
}