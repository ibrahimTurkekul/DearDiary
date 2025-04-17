import 'package:deardiary/features/diary/pages/edit_page.dart';
import 'package:deardiary/features/diary/pages/home_page.dart';
import 'package:flutter/material.dart';
import '../../features/diary/pages/add_entry_page.dart';
import '../../features/diary/pages/preview_page.dart';
import '../../features/diary/models/diary_entry.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Ana sayfa rotası
        return MaterialPageRoute(builder: (_) => DiaryHomePage());
      case '/addEntry':
        return MaterialPageRoute(builder: (_) => AddEntryPage());
      case '/edit':
        final args = settings.arguments as Map<String, dynamic>;
        final DiaryEntry entry = args['entry'];
        return MaterialPageRoute(builder: (_) => EditPage(entry: entry));
      case '/preview':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        print('RouteManager received arguments: $args'); // Debug için
        if (args['initialIndex'] == null) {
          print('Hata: initialIndex null değeri aldı.');
          throw ArgumentError('PreviewPage requires an initialIndex argument.');
        }
        final int initialIndex = args['initialIndex'];
        return MaterialPageRoute(
          builder: (_) => PreviewPage(initialIndex: initialIndex),
        );
      default:
        // Varsayılan olarak 404 sayfası
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