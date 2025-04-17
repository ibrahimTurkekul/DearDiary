import 'package:deardiary/features/diary/pages/edit_page.dart';
import 'package:deardiary/shared/utils/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/diary/providers/diary_provider.dart';
import 'features/diary/hive/hive_boxes.dart';
import 'features/diary/pages/home_page.dart';
import 'features/diary/pages/preview_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveBoxes.initializeHive();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DiaryProvider()..loadEntries(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
  }
