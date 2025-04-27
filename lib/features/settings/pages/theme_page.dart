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
  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    // Seçili temayı SettingsManager'dan yükle
    final settingsManager = Provider.of<SettingsManager>(
      context,
      listen: false,
    );
    selectedTheme =
        settingsManager.settings?.theme ?? 'System Default'; // Varsayılan tema
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Temalar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 sütunlu grid
            crossAxisSpacing: 5, // Sütunlar arası boşluk
            mainAxisSpacing: 16, // Satırlar arası boşluk
          ),
          itemCount: themeService.themeData.length,
          itemBuilder: (context, index) {
            final themeName = themeService.themeData.keys.elementAt(index);
            final themeDetails = themeService.themeData[themeName];
            final isSelected = selectedTheme == themeName;

            return GestureDetector(
              onTap: () {
                _showThemePreview(context, index);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      isSelected
                          ? BorderSide(
                            color: themeDetails?['fabColor'],
                            width: 2,
                          )
                          : BorderSide.none,
                ),
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      themeDetails?['backgroundImage'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      themeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showThemePreview(BuildContext context, int initialIndex) {
    final themeService = Provider.of<ThemeService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int currentIndex = initialIndex;

            void updatePreview(int newIndex) {
              setState(() {
                currentIndex = newIndex;
              });
            }

            final themeName = themeService.themeData.keys.elementAt(
              currentIndex,
            );
            final themeDetails = themeService.themeData[themeName];

            return Scaffold(
              backgroundColor: themeDetails?['primaryColor'],
              appBar: AppBar(
                backgroundColor: themeDetails?['fabColor'],
                title: Text(themeName),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    themeDetails?['backgroundImage'],
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeDetails?['fabColor'],
                    ),
                    onPressed: () {
                      setState(() {
                        selectedTheme = themeName; // Seçilen temayı güncelle
                        final settingsManager = Provider.of<SettingsManager>(
                          context,
                          listen: false,
                        );
                        settingsManager.updateSetting(
                          'theme',
                          themeName,
                        ); // Temayı kaydet
                        themeService.setThemeMode(themeName); // Temayı uygula
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Temayı Seç'),
                  ),
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                color: themeDetails?['fabColor'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed:
                          currentIndex > 0
                              ? () => updatePreview(currentIndex - 1)
                              : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.white,
                      onPressed:
                          currentIndex < themeService.themeData.length - 1
                              ? () => updatePreview(currentIndex + 1)
                              : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
