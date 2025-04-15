import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import '../hive/hive_boxes.dart';

class DiaryProvider with ChangeNotifier {
  List<DiaryEntry> _entries = [];

  List<DiaryEntry> get entries => _entries;

  void loadEntries() {
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    _entries = box.values.toList();
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
    final index = _entries.indexOf(oldEntry);
    if (index != -1) {
      _entries[index] = newEntry;
      notifyListeners();
    }
  }
}
