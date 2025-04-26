import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:deardiary/features/settings/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final themes = [
    {'name': 'Light', 'color': Colors.white},
    {'name': 'Dark', 'color': Colors.black},
    {'name': 'Blue', 'color': Colors.blue},
    {'name': 'Red', 'color': Colors.red},
    {'name': 'Green', 'color': Colors.green},
    {'name': 'Purple', 'color': Colors.purple},
    {'name': 'Orange', 'color': Colors.orange},
    {'name': 'Pink', 'color': Colors.pink},
    {'name': 'Yellow', 'color': Colors.yellow},
    {'name': 'System Default', 'color': Colors.grey[400]},
  ];

  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    // Seçili temayı SettingsManager'dan yükle
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    selectedTheme = settingsManager.settings?.theme ?? 'System Default'; // Varsayılan tema
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temalar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 sütunlu grid
            crossAxisSpacing: 5, // Sütunlar arası boşluk
            mainAxisSpacing: 16, // Satırlar arası boşluk
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            final isSelected = selectedTheme == theme['name'];

            return GestureDetector(
              onTap: () {
                _showThemePreview(context, theme);
              },
              child: Card(
                color: theme['color'] as Color?,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: Colors.blue, width: 2)
                      : BorderSide.none,
                ),
                elevation: 4,
                child: Center(
                  child: Text(
                    theme['name'] as String,
                    style: TextStyle(
                      color: theme['color'] == Colors.black
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showThemePreview(BuildContext context, Map<String, Object?> theme) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${theme['name']} Önizleme'),
          content: Container(
            height: 200,
            color: theme['color'] as Color?,
            child: Center(
              child: Text(
                'Bu tema önizlemesi',
                style: TextStyle(
                  color: theme['color'] == Colors.black
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                final selectedThemeName = theme['name'] as String;
                setState(() {
                  selectedTheme = selectedThemeName; // Seçilen temayı güncelle
                  final settingsManager = Provider.of<SettingsManager>(context, listen: false);
                  settingsManager.updateSetting('theme', selectedThemeName); // Temayı kaydet
                  final themeService = Provider.of<ThemeService>(context, listen: false);
                  themeService.setThemeMode(selectedThemeName); // Temayı uygula
                });
                Navigator.of(context).pop();
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );
  }
}