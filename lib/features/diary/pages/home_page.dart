import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider'ı import ediyoruz
import '../providers/diary_provider.dart';
import 'add_entry_page.dart'; // Günlük ekleme sayfasını import ediyoruz
import 'preview_page.dart'; // Önizleme sayfasını import ediyoruz
import '../widgets/diary_entry_card.dart'; // Günlük kart tasarımı için widget

class DiaryHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryProvider>(
      context,
    ); // DiaryProvider'a erişim
    final entries = provider.entries; // Günlükleri al

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'DearDiary',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ayarlar'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Hakkında'),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('DearDiary'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Arama işlemi
            },
          ),
        ],
      ),
      body:
          entries.isEmpty
              ? Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEntryPage()),
                    );
                  },
                  child: Text(
                    'Henüz hiç günlük eklenmedi.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
              : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PreviewPage(
                                entries: entries, // Tüm günlüklerin listesi
                                currentIndex: index, // Seçilen günlüğün indeksi
                              ),
                        ),
                      );
                    },
                    child: DiaryEntryCard(entry: entry),
                  );
                },
              ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                // Takvim
              },
            ),
            SizedBox(width: 40), // FAB boşluğu
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Profil
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEntryPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
