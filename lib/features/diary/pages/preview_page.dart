import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import '../hive/hive_boxes.dart';

class PreviewPage extends StatefulWidget {
  final int initialIndex;

  const PreviewPage({Key? key, required this.initialIndex}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool isEyeComfortMode = false;
  late int currentIndex;
  late List<DiaryEntry> entries;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<DiaryEntry>(HiveBoxes.diaryBox);
    entries = box.values.toList(); // Günlükleri al
    currentIndex = widget.initialIndex; // Başlangıç indeksini ayarla
  }

  void goToNext() {
    if (currentIndex < entries.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void goToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = entries[currentIndex];
    final int characterCount = currentEntry.content.length;
    final int wordCount = currentEntry.content.split(' ').length;

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Kalem Butonu
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Günlüğü düzenleme sayfasına yönlendirme
              final updatedEntry = await Navigator.pushNamed(
                context,
                '/edit',
                arguments: {'entry': currentEntry},
              );

              // Güncellenmiş veriyi al ve sayfayı yeniden oluştur
              if (updatedEntry != null && updatedEntry is DiaryEntry) {
                setState(() {
                  entries[currentIndex] = updatedEntry;
                });
              }
            },
          ),

          // Göz Konforu Butonu
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                isEyeComfortMode = !isEyeComfortMode;
              });
            },
          ),

          // Üç Noktalı Popup Menü
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'delete':
                  // Günlüğü silme işlemi
                  break;
                case 'pin':
                  // Günlüğü liste başına yerleştirme işlemi
                  break;
                case 'share':
                  // Günlüğü paylaşma işlemi
                  break;
                case 'export':
                  // Günlüğü PDF'ye aktarma işlemi
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'delete', child: const Text('Sil')),
              PopupMenuItem(
                value: 'pin',
                child: const Text('Liste başına yerleştir'),
              ),
              PopupMenuItem(value: 'share', child: const Text('Paylaş')),
              PopupMenuItem(
                value: 'export',
                child: const Text('PDF\'ye Aktar'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text(
                  'Karakter: $characterCount, Kelime: $wordCount',
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: isEyeComfortMode
            ? const Color(0xFFFFF8E1)
            : Colors.white, // Göz konforu modu için sarımtırak renk
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih ve Duygu Durumu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(currentEntry.date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentEntry.mood != null &&
                      currentEntry.mood!.isNotEmpty)
                    Text(
                      currentEntry.mood!,
                      style: const TextStyle(fontSize: 24), // Emoji boyutu
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Başlık
              Text(
                currentEntry.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    currentEntry.content,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
              ),

              // Önceki ve Sonraki Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentIndex > 0 ? goToPrevious : null,
                    child: const Text('Önceki'),
                  ),
                  ElevatedButton(
                    onPressed: currentIndex < entries.length - 1 ? goToNext : null,
                    child: const Text('Sonraki'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}