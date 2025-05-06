import 'package:deardiary/features/settings/repository/settings_repository.dart';
import 'package:deardiary/features/settings/services/notification_service.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:deardiary/features/settings/services/theme_service.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart'; // Günlük kilidi yönetimi
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
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
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
        primaryColor: themeService.primaryColor,
        appBarTheme: AppBarTheme(backgroundColor: Colors.transparent),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themeService.fabColor, // FAB rengi
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color:
                themeService.primaryColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white, // Yazı rengini otomatik ayarla
          ),
        ), // Dinamik ana renk
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

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Uygulama yaşam döngüsünü izlemek için ekle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Gözlemciyi kaldır
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final lockManager = LockManager();

    if (state == AppLifecycleState.resumed || state == AppLifecycleState.detached) {
      final isDiaryLockEnabled = await lockManager.isDiaryLockEnabled();

      if (isDiaryLockEnabled) {
        // Kullanıcıyı şifre doğrulama sayfasına yönlendir
        NavigationService().navigateTo('/patternLockVerify');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLifecycleHandler(
      child: const MyApp(),
    );
  }
}