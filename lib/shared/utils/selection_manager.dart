import 'package:flutter/material.dart';
import 'package:deardiary/features/diary/models/diary_entry.dart';

class SelectionManager extends ChangeNotifier {
  final List<DiaryEntry> _selectedEntries = [];
  bool _isSelectionMode = false;

  List<DiaryEntry> get selectedEntries => List.unmodifiable(_selectedEntries);

  bool get isSelectionMode => _isSelectionMode;

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedEntries.clear();
    }
    notifyListeners();
  }

  void selectEntry(DiaryEntry entry) {
    if (!_selectedEntries.contains(entry)) {
      _selectedEntries.add(entry);
      notifyListeners();
    }
  }

  void deselectEntry(DiaryEntry entry) {
    if (_selectedEntries.contains(entry)) {
      _selectedEntries.remove(entry);
      notifyListeners();
    }
  }

  void toggleEntrySelection(DiaryEntry entry) {
    if (_selectedEntries.contains(entry)) {
      deselectEntry(entry);
    } else {
      selectEntry(entry);
    }
  }

  void clearSelections() {
    _selectedEntries.clear();
    _isSelectionMode = false;
    notifyListeners();
  }
}