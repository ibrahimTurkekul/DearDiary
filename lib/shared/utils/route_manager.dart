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
        final DiaryEntry entry = args['entry'];
        return MaterialPageRoute(builder: (_) => PreviewPage(entry: entry));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('404 - Sayfa Bulunamadı'),
            ),
          ),
        );
    }
  }
}