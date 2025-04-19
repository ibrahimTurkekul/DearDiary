import 'package:deardiary/features/diary/models/diary_entry.dart';
import 'package:deardiary/shared/utils/entry_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../widgets/year_grouped_diary_list.dart';
import '../../../shared/utils/navigation_service.dart';

class DiaryHomePage extends StatelessWidget {
  const DiaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Günlük verilerini sağlayıcıdan alıyoruz
    final provider = Provider.of<DiaryProvider>(context);
    final groupedEntries = provider.groupedEntries;

    return Scaffold(
      drawer: const _DiaryDrawer(), // Drawer ayrı bir widget olarak tanımlandı
      appBar: const _DiaryAppBar(), // AppBar ayrı bir widget olarak tanımlandı
      body: _buildBody(groupedEntries, provider),
      bottomNavigationBar: const _DiaryBottomNavigationBar(), // BottomNavigationBar ayrı bir widget olarak tanımlandı
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationService().navigateToAddEntry();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Body kısmını bir yardımcı metod olarak oluşturduk
  Widget _buildBody(Map<int, List<DiaryEntry>> groupedEntries, DiaryProvider provider) {
    if (groupedEntries.isEmpty) {
      return const Center(
        child: Text(
          'Henüz hiç günlük eklenmedi.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return YearGroupedDiaryList(
      groupedEntries: groupedEntries,
      onTap: (entry) => EntryActions.handleTap(entry, provider),
      onLongPress: (entry) => EntryActions.handleLongPress(entry),
    );
  }
}

// Drawer için ayrı bir widget
class _DiaryDrawer extends StatelessWidget {
  const _DiaryDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple),
            child: Text(
              'DearDiary',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              // Ayarlar ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Hakkında'),
            onTap: () {
              // Hakkında ekranına geçiş
            },
          ),
        ],
      ),
    );
  }
}

// AppBar için ayrı bir widget
class _DiaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DiaryAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('DearDiary'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Arama işlemi
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// BottomNavigationBar için ayrı bir widget
class _DiaryBottomNavigationBar extends StatelessWidget {
  const _DiaryBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Takvim ekranına geçiş
            },
          ),
          const SizedBox(width: 40), // FAB boşluğu
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profil ekranına geçiş
            },
          ),
        ],
      ),
    );
  }
}