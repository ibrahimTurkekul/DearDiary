import 'package:flutter/material.dart';
import '../../features/diary/pages/add_entry_page.dart';
import '../../features/diary/pages/preview_page.dart';
import '../../features/diary/models/diary_entry.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/addEntry':
        return MaterialPageRoute(builder: (_) => AddEntryPage());
      case '/preview':
        final args = settings.arguments as Map<String, dynamic>;
        final List<DiaryEntry> entries = args['entries'];
        final int currentIndex = args['currentIndex'];
        return MaterialPageRoute(
          builder:
              (_) => PreviewPage(
                entries: entries, // Günlüklerin tamamını gönder
                currentIndex: currentIndex, // Seçili günlüğün indeksini gönder
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  Scaffold(body: Center(child: Text('404 - Sayfa Bulunamadı'))),
        );
    }
  }
}
