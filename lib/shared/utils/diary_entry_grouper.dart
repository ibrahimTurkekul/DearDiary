import '../../features/diary/models/diary_entry.dart';

class DiaryEntryGrouper {
  static Map<int, List<DiaryEntry>> groupByYear(List<DiaryEntry> entries) {
    final groupedEntries = <int, List<DiaryEntry>>{};
    for (var entry in entries) {
      final year = entry.date.year;
      groupedEntries.putIfAbsent(year, () => []);
      groupedEntries[year]!.add(entry);
    }
    return groupedEntries;
  }
}