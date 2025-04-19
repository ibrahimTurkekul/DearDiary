import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import 'diary_entry_card.dart';

class YearGroupedDiaryList extends StatelessWidget {
  final Map<int, List<DiaryEntry>> groupedEntries;
  final Function(DiaryEntry) onTap;
  final Function(DiaryEntry) onLongPress;

  const YearGroupedDiaryList({
    Key? key,
    required this.groupedEntries,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Yılları ters sıralıyoruz (En yeni yıl üstte)
    final years = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: years.length,
      itemBuilder: (context, yearIndex) {
        final year = years[yearIndex];
        // Her yılın günlüklerini ters sıralıyoruz (En yeni günlük üstte)
        final entries = List.from(groupedEntries[year]!)..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$year',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            // Günlükleri map ile dönüyoruz
            ...entries.map((entry) {
              return GestureDetector(
                onTap: () => onTap(entry),
                onLongPress: () => onLongPress(entry),
                child: DiaryEntryCard(
                  entry: entry,
                  onTap: () => onTap(entry),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}