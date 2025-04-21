import '../models/diary_entry.dart';

/// DiaryRepository arayüzü, günlük işlemleri için bir sözleşme (interface) tanımlar.
abstract class DiaryRepository {
  List<DiaryEntry> get entries; // Günlüklerin listesi
  Map<int, List<DiaryEntry>> get groupedEntries; // Yıllara göre gruplandırılmış günlükler

  void loadEntries(); // Günlükleri yükleme
  void addEntry(DiaryEntry entry); // Yeni günlük ekleme
  void deleteEntry(int index); // Günlük silme
  void updateEntry(DiaryEntry oldEntry, DiaryEntry newEntry); // Günlüğü güncelleme
}