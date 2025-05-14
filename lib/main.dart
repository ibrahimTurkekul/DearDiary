import 'package:flutter/material.dart';
import 'package:deardiary/features/settings/repository/settings_repository.dart';
import 'package:deardiary/features/settings/services/notification_service.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:deardiary/features/settings/services/theme_service.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart'; // Günlük kilidi yönetimi
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/shared/utils/route_manager.dart';
import 'package:deardiary/shared/utils/selection_manager.dart';
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

  final lockManager = LockManager(); // Günlük kilidi kontrolü için

  // Günlük kilidi kontrolü
  final isDiaryLockEnabled = await lockManager.isDiaryLockEnabled();
  final lockType =
      await lockManager.getActiveLockType(); // PIN veya Pattern kontrolü

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => SelectionManager()),
        Provider<NavigationService>(
          create: (_) => NavigationService(),
          lazy: false,
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
      child: AppEntryPoint(
        initialRoute:
            isDiaryLockEnabled
                ? (lockType == 'pin'
                    ? '/pinLockVerify'
                    : '/patternLockVerify') // Kilit türüne göre rota
                : '/', // Günlük kilidi devre dışıysa ana sayfaya yönlendir
      ),
    ),
  );
}

class AppEntryPoint extends StatelessWidget {
  final String initialRoute;

  const AppEntryPoint({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleHandler(child: MyApp(initialRoute: initialRoute));
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // ThemeService'i dinlemek için Provider kullan
    final themeService = Provider.of<ThemeService>(context);
    final navigationService = Provider.of<NavigationService>(
      context,
      listen: false,
    );

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
      navigatorKey: navigationService.navigatorKey,
      initialRoute: initialRoute, // Günlük kilidine göre başlat
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Uygulama yaşam döngüsünü izle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final lockManager = LockManager();
    final navigationService = NavigationService();

    if (state == AppLifecycleState.resumed && !lockManager.isAuthenticated) {
      final isDiaryLockEnabled = await lockManager.isDiaryLockEnabled();

      if (isDiaryLockEnabled) {
        final lockType = await lockManager.getActiveLockType();
        final currentContext = navigationService.navigatorKey.currentContext;

        if (currentContext == null) {
          print(
            "Hata: currentContext null! NavigationService navigatorKey doğru atanmış mı?",
          );
          return; // Yönlendirme yapılmaz
        }

        final currentRoute = ModalRoute.of(currentContext);

        if (currentRoute == null) {
          print("Hata: currentContext bir ModalRoute ile ilişkilendirilmemiş!");
          // Varsayılan bir rota belirleyin
          navigationService.navigateTo(
            lockType == 'pattern' ? '/patternLockVerify' : '/pinLockVerify',
          );
          return;
        }

        // Rotayı kontrol et ve yönlendir
        if ((lockType == 'pattern' &&
                currentRoute.settings.name != '/patternLockVerify') ||
            (lockType == 'pin' &&
                currentRoute.settings.name != '/pinLockVerify')) {
          navigationService.navigateTo(
            lockType == 'pattern' ? '/patternLockVerify' : '/pinLockVerify',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
