import 'package:deardiary/features/diary/widgets/year_grouped_diary_list.dart';
import 'package:deardiary/shared/utils/confirmation_dialog.dart';
import 'package:deardiary/shared/utils/entry_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../../../shared/utils/navigation_service.dart';
import '../../../shared/utils/selection_manager.dart';
import '../../settings/services/theme_service.dart';
import '../providers/diary_provider.dart';

class DiaryHomePage extends StatelessWidget {
  const DiaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectionManager = Provider.of<SelectionManager>(context);
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar'ı arka plana taşır
      drawer: const _DiaryDrawer(), // Tek bir drawer tanımı
      body: Stack(
        children: [
          // Günlük Listesi ve Arka Plan
          CustomScrollView(
            slivers: [
              // Dinamik SliverAppBar
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height / 3, // Resim yüksekliği
                floating: false,
                pinned: true, // Kaydırıldığında AppBar sabit kalır
                backgroundColor: Colors.blueGrey, // AppBar arka plan rengi
                elevation: 0.0,
                leading: selectionManager.isSelectionMode
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: selectionManager.clearSelections, // Seçim modunu iptal et
                      )
                    : Builder(
                        builder: (context) {
                          return IconButton(
                            icon: const Icon(Icons.menu), // Drawer açma ikonu
                            onPressed: () {
                              Scaffold.of(context).openDrawer(); // Drawer'ı açar
                            },
                          );
                        },
                      ),
                title: selectionManager.isSelectionMode
                    ? Text('${selectionManager.selectedEntries.length} Seçildi')
                    : const Text('DearDiary'),
                actions: selectionManager.isSelectionMode
                    ? [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Silme işlemi için onay penceresi
                            final confirmed = await showConfirmationDialog(
                              context: context,
                              title: "Günlükleri Sil",
                              content: "Seçili günlükleri silmek istediğinize emin misiniz?",
                              confirmText: "Sil",
                              cancelText: "İptal",
                            );
                            if (confirmed == true) {
                              final provider = Provider.of<DiaryProvider>(context, listen: false);
                              for (final entry in selectionManager.selectedEntries) {
                                provider.deleteEntry(entry); // Günlük silme işlemi
                              }
                              selectionManager.clearSelections(); // Seçim modunu temizle

                              // Snackbar ile kullanıcıyı bilgilendir
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Günlükler silindi"),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.teal,
                                  behavior: SnackBarBehavior.floating, // Snackbar yukarıda "float" edecek
                                  margin: const EdgeInsets.all(16), // Kenarlardan boşluk bırak
                                ),
                              );
                            }
                          },
                        ),
                      ]
                    : [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            NavigationService().navigateTo('/search');
                          },
                        ),
                      ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    themeService.backgroundImage, // Temadan gelen resim
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Günlük Listesi
              Consumer<DiaryProvider>(
                builder: (context, provider, child) {
                  final groupedEntries = provider.groupedEntries; // Günlükler Map yapısı
                  if (groupedEntries.isEmpty) {
                    // Eğer günlük yoksa boş bir mesaj göster
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Henüz hiç günlük eklenmedi.',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }
                  return YearGroupedDiaryList(
                    groupedEntries: groupedEntries,
                    onTap: (entry) {
                      if (selectionManager.isSelectionMode) {
                        selectionManager.toggleEntrySelection(entry);
                      } else {
                        EntryActions.handleTap(entry, provider);
                      }
                    },
                    onLongPress: (entry) {
                      if (!selectionManager.isSelectionMode) {
                        selectionManager.toggleSelectionMode(); // Seçim moduna geç
                      }
                      selectionManager.selectEntry(entry); // İlk basılan günlüğü seç
                    },
                  );
                },
              ),
            ],
          ),
          // Alt Kısımda Sabit FAB Butonlar
          Positioned(
            bottom: 16, // Alt kısımdan boşluk
            left: 0,
            right: 0,
            child: _CustomFloatingButtons(themeService: themeService),
          ),
        ],
      ),
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
              NavigationService().navigateTo('/theme');
            },
          ),
          Divider(height: 30, color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Günlük Kilidi'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Yedekle ve Geri Yükle'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('İçe ve Dışa Aktar'),
            onTap: () {},
          ),
          Divider(height: 30, color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Bağış Yap'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Uygulamayı Paylaş'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('FAQ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onTap: () {
              NavigationService().navigateTo('/settings');
            },
          ),
        ],
      ),
    );
  }
}

// Alt Kısımda Sabit FAB Butonları
class _CustomFloatingButtons extends StatelessWidget {
  final ThemeService themeService;

  const _CustomFloatingButtons({required this.themeService});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'calendar_button',
          mini: true,
          backgroundColor: const Color(0x33111111), // Düz transparan gri
          shape: const CircleBorder(),
          onPressed: () {
            NavigationService().navigateTo('/calendar');
          },
          child: const Icon(Icons.calendar_month, size: 18.0),
        ),
        RippleAnimation(
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
            backgroundColor: themeService.fabColor, // FAB buton rengi temaya bağlı
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
        FloatingActionButton(
          heroTag: 'profile_button',
          mini: true,
          backgroundColor: const Color(0x33111111), // Düz transparan gri
          shape: const CircleBorder(),
          onPressed: () {
            // Profil ekranına geçiş
          },
          child: const Icon(Icons.person, size: 18.0),
        ),
      ],
    );
  }
}