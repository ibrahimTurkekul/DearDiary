import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class PreviewPage extends StatefulWidget {
  final List<DiaryEntry>? entries; // Tüm günlükler (nullable hale getirildi)
  final int? currentIndex; // Şu anki günlük indeksi (nullable hale getirildi)

  const PreviewPage({
    Key? key,
    required this.entries,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late int currentIndex;
  late List<DiaryEntry> entries;
  bool isEyeComfortMode = false;

  @override
  void initState() {
    super.initState();

    // entries ve currentIndex için güvenli başlatma
    entries = widget.entries ?? []; // Eğer null ise boş liste oluşturur
    currentIndex = (widget.currentIndex != null &&
            widget.currentIndex! >= 0 &&
            widget.currentIndex! < entries.length)
        ? widget.currentIndex!
        : -1; // Geçersiz indeks için -1 atanır
  }

  @override
  Widget build(BuildContext context) {
    // Eğer entries boşsa veya currentIndex geçersizse bir hata ekranı göster
    if (entries.isEmpty || currentIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Günlük verisi bulunamadı veya geçersiz indeks.',
                style: TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Bir önceki sayfaya dön
                },
                child: const Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

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
              const PopupMenuItem(value: 'delete', child: Text('Sil')),
              const PopupMenuItem(
                value: 'pin',
                child: Text('Liste başına yerleştir'),
              ),
              const PopupMenuItem(value: 'share', child: Text('Paylaş')),
              const PopupMenuItem(
                value: 'export',
                child: Text('PDF\'ye Aktar'),
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
                  // Önceki Butonu
                  TextButton(
                    onPressed: currentIndex > 0
                        ? () {
                            setState(() {
                              currentIndex--;
                            });
                          }
                        : null, // İlk günlükteyken butonu pasif yap
                    child: Text(
                      'Önceki',
                      style: TextStyle(
                        color: currentIndex > 0
                            ? Colors.blue
                            : Colors.grey, // Pasif renk
                      ),
                    ),
                  ),

                  // Sonraki Butonu
                  TextButton(
                    onPressed: currentIndex < entries.length - 1
                        ? () {
                            setState(() {
                              currentIndex++;
                            });
                          }
                        : null, // Son günlükteyken butonu pasif yap
                    child: Text(
                      'Sonraki',
                      style: TextStyle(
                        color: currentIndex < entries.length - 1
                            ? Colors.blue
                            : Colors.grey, // Pasif renk
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}