import 'package:deardiary/features/diary/pages/edit_page.dart';
import 'package:deardiary/features/diary/pages/home_page.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import '../../features/diary/pages/add_entry_page.dart';
import '../../features/diary/pages/preview_page.dart';
import '../../features/diary/models/diary_entry.dart';

class RouteManager {
  static BuildContext? get context => NavigationService().navigatorKey.currentContext;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Ana sayfa rotası
        return MaterialPageRoute(builder: (_) => const DiaryHomePage());

      case '/addEntry':
        return MaterialPageRoute(builder: (_) => const AddEntryPage());

      case '/edit':
        // Düzenleme sayfasına geçiş
        if (settings.arguments == null) {
          return _errorRoute('EditPage requires a DiaryEntry argument.');
        }
        final args = settings.arguments as Map<String, dynamic>;
        final DiaryEntry? entry = args['entry'];
        if (entry == null) {
          return _errorRoute('EditPage received a null DiaryEntry.');
        }
        return MaterialPageRoute(builder: (_) => EditPage(entry: entry));

      case '/preview':
        // Önizleme sayfasına geçiş
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        if (args['initialIndex'] == null) {
          return _errorRoute('PreviewPage requires an initialIndex argument.');
        }
        final int initialIndex = args['initialIndex'];
        return MaterialPageRoute(
          builder: (_) => PreviewPage(initialIndex: initialIndex),
        );

      default:
        // Varsayılan olarak 404 sayfası
        return _errorRoute('404 - Sayfa Bulunamadı');
    }
  }

  /// Hata için varsayılan bir route döner
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}