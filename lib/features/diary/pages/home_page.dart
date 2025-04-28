import 'package:deardiary/features/diary/models/diary_entry.dart';
import 'package:deardiary/shared/utils/entry_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../providers/diary_provider.dart';
import '../widgets/year_grouped_diary_list.dart';
import '../../../shared/utils/navigation_service.dart';
import '../../../shared/utils/selection_manager.dart';
import '../../../shared/utils/confirmation_dialog.dart';
import '../../settings/services/theme_service.dart';

class DiaryHomePage extends StatelessWidget {
  const DiaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectionManager = Provider.of<SelectionManager>(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      drawer: const _DiaryDrawer(),
      appBar:
          selectionManager.isSelectionMode
              ? _buildSelectionAppBar(selectionManager, context)
              : const _DiaryAppBar(),
      body: Consumer<DiaryProvider>(
        builder: (context, provider, child) {
          final groupedEntries = provider.groupedEntries;
          return _buildBody(
            groupedEntries,
            provider,
            selectionManager,
            themeService,
            context,
          );
        },
      ),
      bottomNavigationBar: const _DiaryBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: RippleAnimation(
        color: Colors.grey,
        delay: const Duration(milliseconds: 300),
        repeat: true,
        minRadius: 30,
        maxRadius: 30,
        ripplesCount: 1,
        duration: const Duration(milliseconds: 8 * 300),
        child: FloatingActionButton(
          onPressed: () {
            NavigationService().navigateToAddEntry();
          },
          backgroundColor:
              themeService.fabColor, // FAB buton rengi temaya bağlı
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  AppBar _buildSelectionAppBar(
    SelectionManager selectionManager,
    BuildContext context,
  ) {
    final provider = Provider.of<DiaryProvider>(context, listen: false);

    return AppBar(
      title: Text('${selectionManager.selectedEntries.length} Seçildi'),
      backgroundColor: Colors.blueGrey,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: selectionManager.clearSelections,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final confirmed = await showConfirmationDialog(
              context: context,
              title: "Günlükleri Sil",
              content: "Seçili günlükleri silmek istediğinize emin misiniz?",
              confirmText: "Sil",
              cancelText: "İptal",
            );
            if (confirmed == true) {
              for (final entry in selectionManager.selectedEntries) {
                provider.deleteEntry(entry);
              }
              selectionManager.clearSelections();

              // Günlükler silindikten sonra Snackbar gösteriliyor
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Günlükler silindi"),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.teal,
                  behavior:
                      SnackBarBehavior
                          .floating, // Snackbar yukarıda "float" edecek
                  margin: const EdgeInsets.all(16), // Kenarlardan boşluk bırak
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody(
    Map<int, List<DiaryEntry>> groupedEntries,
    DiaryProvider provider,
    SelectionManager selectionManager,
    ThemeService themeService,
    BuildContext context,
  ) {
    if (groupedEntries.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                'assets/images/empty_state.png',
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ), // Ortada gösterilecek resim
            ),
          ),
          Image.asset(
            themeService.backgroundImage, // Tema resmi en altta
            height: MediaQuery.of(context).size.height / 3, // Sayfanın 3'te 1'i
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      );
    }

    return Column(
      children: [
        Image.asset(
          themeService.backgroundImage, // Tema resmi en üstte
          height: MediaQuery.of(context).size.height / 3, // Sayfanın 3'te 1'i
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Expanded(
          child: YearGroupedDiaryList(
            groupedEntries: groupedEntries,
            onTap: (entry) {
              if (selectionManager.isSelectionMode) {
                selectionManager.toggleEntrySelection(entry);
              } else {
                EntryActions.handleTap(entry, provider);
              }
            },
            onLongPress: (entry) {
              final selectionManager = Provider.of<SelectionManager>(
                context,
                listen: false,
              );
              if (!selectionManager.isSelectionMode) {
                selectionManager.toggleSelectionMode(); // Seçim moduna geç
              }
              selectionManager.selectEntry(entry); // İlk basılan günlüğü seç
            },
          ),
        ),
      ],
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
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            onTap: () {
              // Tema Seçenekleri ekranına geçiş
              NavigationService().navigateTo('/theme');
            },
          ),
          Divider(height: 30, color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Günlük Kilidi'),
            onTap: () {
              // Kilidi ayarlama ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Yedekle ve Geri Yükle'),
            onTap: () {
              // Yedekleme ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('İçe ve Dışa Aktar'),
            onTap: () {
              // içe ve dışa aktarma ekranına geçiş
            },
          ),
          Divider(height: 30, color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Bağış Yap'),
            onTap: () {
              // Bağış ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Uygulamayı Paylaş'),
            onTap: () {
              // Uygulama paylaşma ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('FAQ'),
            onTap: () {
              // Sık sorulan sorular ekranına geçiş
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              // Ayarlar ekranına geçiş
              NavigationService().navigateTo('/settings');
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
            NavigationService().navigateTo('/search');
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
              NavigationService().navigateTo('/calendar');
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
