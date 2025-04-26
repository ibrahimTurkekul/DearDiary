import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../../../shared/utils/selection_manager.dart';
import 'diary_entry_card.dart';

class YearGroupedDiaryList extends StatelessWidget {
  final Map<int, List<DiaryEntry>> groupedEntries;
  final Function(DiaryEntry) onTap;
  final Function(DiaryEntry) onLongPress;

  const YearGroupedDiaryList({
    super.key,
    required this.groupedEntries,
    required this.onTap,
    required this.onLongPress,
  });

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
              padding: const EdgeInsets.only(top: 10.0, left: 10.0,bottom: BorderSide.strokeAlignCenter),
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
              return Selector<SelectionManager, bool>(
                selector: (_, selectionManager) => selectionManager.selectedEntries.contains(entry),
                builder: (context, isSelected, child) {
                  return GestureDetector(
                    onTap: () {
                      final selectionManager = Provider.of<SelectionManager>(context, listen: false);
                      if (selectionManager.isSelectionMode) {
                        selectionManager.toggleEntrySelection(entry);
                      } else {
                        onTap(entry);
                      }
                    },
                    onLongPress: () {
                      final selectionManager = Provider.of<SelectionManager>(context, listen: false);
                      if (!selectionManager.isSelectionMode) {
                        selectionManager.toggleSelectionMode();
                      }
                      selectionManager.toggleEntrySelection(entry);
                      onLongPress(entry);
                    },
                    child: Container(
                      color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                      child: DiaryEntryCard(
                        entry: entry,
                        onTap: () => onTap(entry),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}