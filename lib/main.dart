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
import 'features/diary/providers/diary_provider.dart'; // DiaryProvider sınıfı
import 'features/diary/hive/hive_boxes.dart';

Future<void> initializeApp() async {
  await Hive.initFlutter();
  await HiveBoxes.initializeHive();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initializeNotifications();
  
  await initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => SelectionManager()),
        ChangeNotifierProvider(create: (_) => ThemeService()), 
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
      theme: ThemeData.light(), // Açık tema
      darkTheme: ThemeData.dark(), // Koyu tema
      themeMode: themeService.themeMode, // Dinamik tema modu
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      initialRoute: '/',
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}