import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/features/diary/models/diary_entry.dart';
import 'package:deardiary/features/diary/providers/diary_provider.dart';

class EntryActions {
  // Günlük üzerine tıklama işlemi
  static void handleTap(DiaryEntry entry, DiaryProvider provider) {
    final index = provider.entries.indexOf(entry);
    NavigationService().navigateToPreview(index); // Preview sayfasına git
  }

  // Günlük üzerine uzun basma işlemi
  static void handleLongPress(DiaryEntry entry) {
    // Uzun basıldığında yapılacak işlem (örneğin, silme veya düzenleme menüsü)
    print('Uzun basıldı: ${entry.title}');
  }
}