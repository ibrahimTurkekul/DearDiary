import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deardiary/features/diary/providers/diary_provider.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/features/diary/widgets/diary_entry_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = ''; // Kullanıcının arama sorgusu

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final filteredEntries = _searchQuery.isEmpty
        ? []
        : provider.entries.where((entry) {
            final titleLower = entry.title.toLowerCase();
            final contentLower = entry.content.toLowerCase();
            final queryLower = _searchQuery.toLowerCase();
            return titleLower.contains(queryLower) || contentLower.contains(queryLower);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true, // İmleci otomatik olarak TextField üzerine getirir
          decoration: const InputDecoration(
            hintText: "Günlüklerde ara...",
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query; // Kullanıcının arama sorgusunu güncelle
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Sayfayı kapat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Sonuçlar Listesi
          Expanded(
            child: filteredEntries.isEmpty
                ? const Center(
                    child: Text(
                      "Arama sonuçları burada gösterilecek.",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return DiaryEntryCard(
                        entry: entry,
                        onTap: () {
                          final correctIndex = provider.entries.indexOf(entry);
                          navigationService.navigateToPreview(correctIndex);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}