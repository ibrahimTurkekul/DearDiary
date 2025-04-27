import 'package:deardiary/features/settings/repository/settings_repository.dart';
import 'package:deardiary/features/settings/services/notification_service.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:deardiary/features/settings/services/theme_service.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/shared/utils/route_manager.dart';
import 'package:deardiary/shared/utils/selection_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'features/diary/providers/diary_provider.dart'; // DiaryProvider sınıfı
import 'features/diary/hive/hive_boxes.dart';

Future<void> initializeApp() async {
  await Hive.initFlutter();
  await HiveBoxes.initializeHive();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NotificationService'i başlat
  final notificationService = NotificationService();
  await notificationService.initializeNotifications();
  tz.initializeTimeZones(); // Zaman dilimlerini başlat
  await initializeApp();

  // ThemeService'i başlat ve JSON verilerini yükle
  final themeService = ThemeService();
  await themeService.loadThemes();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => SelectionManager()),
        ChangeNotifierProvider(
          create: (_) => themeService,
        ), // Tema servisini sağlayıcıya ekledik
        ChangeNotifierProvider(create: (_) => NotificationService()),
        Provider<SettingsRepository>(create: (_) => SettingsRepository()),
        ChangeNotifierProvider(
          create: (context) {
            final manager = SettingsManager(context.read<SettingsRepository>());
            manager.loadSettings(); // Ayarları yükle
            return manager;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeService'i dinlemek için Provider kullan
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      theme: ThemeData(
        primaryColor: themeService.primaryColor, // Dinamik ana renk
      ), // Açık tema
      darkTheme: ThemeData.dark(), // Koyu tema
      themeMode: themeService.themeMode, // Dinamik tema modu
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      initialRoute: '/',
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}
