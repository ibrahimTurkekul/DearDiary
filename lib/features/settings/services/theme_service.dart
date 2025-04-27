import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle için gerekli

class ThemeService with ChangeNotifier {
  // Mevcut tema modu (light, dark, system)
  ThemeMode _themeMode = ThemeMode.system;

  // Temaya ait diğer özellikler (arka plan resmi ve FAB rengi)
  String _backgroundImage = '';
  Color _primaryColor = Colors.blue; // Varsayılan tema rengi
  Color _fabColor = Colors.blue; // FAB buton varsayılan rengi

  // JSON'dan yüklenecek temalar
  Map<String, Map<String, dynamic>> _themeData = {};

  // Getter metotları
  ThemeMode get themeMode => _themeMode;
  String get backgroundImage => _backgroundImage;
  Color get primaryColor => _primaryColor;
  Color get fabColor => _fabColor;
  Map<String, Map<String, dynamic>> get themeData => _themeData;

  // Temaları JSON dosyasından yükleme
  Future<void> loadThemes() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/themes/themes.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _themeData = jsonData.map((key, value) {
        return MapEntry(key, {
          'themeMode':
              value['themeMode'] == 'light' ? ThemeMode.light : ThemeMode.dark,
          'backgroundImage': value['backgroundImage'],
          'primaryColor': _hexToColor(value['primaryColor']),
          'fabColor': _hexToColor(value['fabColor']),
        });
      });

      notifyListeners(); // Dinleyicilere temaların yüklendiğini bildir
    } catch (e) {
      print('Tema verileri yüklenirken hata oluştu: $e');
    }
  }

  // Hex renk kodunu Color nesnesine dönüştürme
  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  // Temayı ayarlama metodu
  void setThemeMode(String selectedTheme) {
    if (_themeData.containsKey(selectedTheme)) {
      _themeMode = _themeData[selectedTheme]!['themeMode'];
      _backgroundImage = _themeData[selectedTheme]!['backgroundImage'];
      _primaryColor = _themeData[selectedTheme]!['primaryColor'];
      _fabColor = _themeData[selectedTheme]!['fabColor'];
      notifyListeners(); // Tüm dinleyicilere değişikliği bildir
    }
  }

  // Dark mode kontrolü
  bool isDarkMode() {
    return _themeMode == ThemeMode.dark;
  }
}
