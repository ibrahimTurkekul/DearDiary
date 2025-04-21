import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/shared/utils/route_manager.dart';
import 'package:deardiary/shared/utils/selection_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/diary/providers/diary_provider.dart'; // DiaryProvider sınıfı
import 'features/diary/hive/hive_boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveBoxes.initializeHive();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => SelectionManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      initialRoute: '/',
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}