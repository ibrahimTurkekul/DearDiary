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
      extendBodyBehindAppBar: true,
      backgroundColor: themeService.primaryColor,
      drawer: const _DiaryDrawer(),
      appBar:
          selectionManager.isSelectionMode
              ? _buildSelectionAppBar(selectionManager, context)
              : const _DiaryAppBar(),
      body: Stack(
        children: [
          Consumer<DiaryProvider>(
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
      Positioned(
            bottom: 16, // Alt kısımdan boşluk
            left: 0,
            right: 0,
            child: _CustomFloatingButtons(themeService: themeService),
          ),
      ],) 
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
      return Stack(
      children: [
        // Arka planı tamamen kaplayan resim
        Image.asset(
          'assets/themes/light.png', // Günlük olmayan duruma özel resim
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Popup mesaj
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Henüz bir günlük eklenmedi.',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Yeni bir günlük eklemek için aşağıdaki \'+\' butonuna tıklayın.',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.arrow_downward,
                size: 48,
                color: Colors.white70,
              ),
            ],
          ),
        ),],);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset('assets/themes/ygl.png').image,
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
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
            ),),
      ],
    );
  }
}

// Drawer için ayrı bir widget
class _DiaryDrawer extends StatelessWidget {
  const _DiaryDrawer();
  
  @override
  Widget build(BuildContext context) {
  final navigationService = Provider.of<NavigationService>(context, listen: false);  
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
              navigationService.navigateTo('/theme');
            },
          ),
          Divider(height: 30, color: Colors.grey[300]),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Günlük Kilidi'),
            onTap: () => navigationService.navigateTo('/diaryLock'),
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
              navigationService.navigateTo('/settings');
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
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    return AppBar(
      title: const Text('DearDiary'),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Arama işlemi
            navigationService.navigateTo('/search');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomFloatingButtons extends StatelessWidget {
  final ThemeService themeService;

  const _CustomFloatingButtons({required this.themeService});

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'calendar_button',
          mini: true,
          backgroundColor: Colors.grey[400]?.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () {
            navigationService.navigateTo('/calendar');
          },
          child: const Icon(Icons.calendar_month,size: 18.0,),
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
              navigationService.navigateToAddEntry();
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
          backgroundColor: Colors.grey[400]?.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () {
            // Profil ekranına geçiş
          },
          child: const Icon(Icons.person,size: 18.0,),
        ),
      ],
    );
  }
}