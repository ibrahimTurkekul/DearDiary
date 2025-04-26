import 'package:flutter/material.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(String selectedTheme) {
    if (selectedTheme == 'Light') {
      _themeMode = ThemeMode.light;
    } else if (selectedTheme == 'Dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners(); // Tüm dinleyicilere değişiklik bildir
  }

  bool isDarkMode() {
    return _themeMode == ThemeMode.dark;
  }
}