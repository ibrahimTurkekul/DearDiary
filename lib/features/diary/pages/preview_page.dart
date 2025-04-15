import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class PreviewPage extends StatefulWidget {
  final DiaryEntry entry;

  const PreviewPage({Key? key, required this.entry}) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool isEyeComfortMode = false;
  late DiaryEntry currentEntry;

  @override
  void initState() {
    super.initState();
    // Mevcut günlüğü başlat
    currentEntry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
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
                  currentEntry = updatedEntry;
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
            ],
          ),
        ),
      ),
    );
  }
}