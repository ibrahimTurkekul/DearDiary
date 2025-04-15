import 'package:hive/hive.dart';
import '../models/diary_entry.dart';

class HiveBoxes {
  static String diaryBox = 'diary_entries';

  static Future<void> initializeHive() async {
    Hive.registerAdapter(DiaryEntryAdapter());
    await Hive.openBox<DiaryEntry>(diaryBox);
  }
}