import 'package:deardiary/shared/utils/diary_entry_grouper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import '../hive/hive_boxes.dart';

class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];

  List<DiaryEntry> get entries => _entries;
  Map<int, List<DiaryEntry>> get groupedEntries {
    return DiaryEntryGrouper.groupByYear(_entries);
  }

  void loadEntries() {
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    _entries = box.values.toList();
    // Debug için ekleme
    print('Loaded entries: $_entries');
    notifyListeners(); // UI'yi güncellemek için çağrılır
  }

  void addEntry(DiaryEntry entry) {
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    box.add(entry);
    loadEntries(); // Yeni günlük eklendiğinde listeyi günceller
  }

  void deleteEntry(int index) {
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    box.deleteAt(index);
    loadEntries(); // Günlük silindiğinde listeyi günceller
  }

  void updateEntry(DiaryEntry oldEntry, DiaryEntry newEntry) {
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    final index = _entries.indexOf(oldEntry);

    if (index != -1) {
      // Hive veritabanındaki kaydı güncelle
      box.putAt(index, newEntry);

      // _entries listesini güncelle
      _entries[index] = newEntry;
      notifyListeners(); // UI'yi güncellemek için çağrılır
    }
  }
}