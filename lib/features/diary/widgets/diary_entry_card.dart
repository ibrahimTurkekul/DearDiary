import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';

class DiaryEntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final bool displayOnlyTime; // Yeni özellik

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.displayOnlyTime = false, // Varsayılan olarak false
  });

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);
    final dateFormat = settingsManager.settings?.dateFormat ?? 'dd MMM'; // Varsayılan format
    final timeFormat = settingsManager.settings?.timeFormat ?? '24-hour'; // Varsayılan saat formatı
    final formattedDate = _formatDateForDisplay(entry.date, dateFormat, timeFormat);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Container(
          width: double.infinity, // Sayfa genişliği kadar olacak
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Sağ üst köşede emoji (Mood)
              if (entry.mood != null && entry.mood!.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    entry.mood!,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarih ve Saat Bilgisi Yan Yana
                  if (!displayOnlyTime) // Eğer sadece saat gösterilmeyecekse
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline, // Taban hizalaması
                      textBaseline: TextBaseline.alphabetic, // Metni alfabetik hizala
                      children: _buildFormattedDate(entry.date, dateFormat, timeFormat),
                    ),
                  if (displayOnlyTime) // Eğer sadece saat gösterilecekse
                    Text(
                      _formatOnlyTime(entry.date, timeFormat), // Saat bilgisi
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Günlük Başlık
                  // Eğer sadece saat gösterilmeyecekse
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Günlük İçeriği (İlk Cümle)
                  // Eğer sadece saat gösterilmeyecekse
                    Text(
                      "${entry.content.split('.').first}...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarihi belirli bir formata göre yan yana formatlar
  List<Widget> _buildFormattedDate(DateTime date, String dateFormat, String timeFormat) {
    String day = DateFormat('dd').format(date); // Gün
    String month = DateFormat('MMM').format(date); // Ay
    String time = '';
    String weekday = '';

    // Saat biçimini belirle
    final timePattern = timeFormat == '24-hour' ? 'HH:mm' : 'hh:mm a';

    // Formatlara göre bölümleri ayır
    switch (dateFormat) {
      case 'dd-MMM-yyyy':
        break; // Sadece Gün ve Ay bilgisi gösterilecek
      case 'dd-MMM-yyyy HH:mm':
        time = DateFormat(timePattern).format(date); // Örnek: 14:30 veya 2:30 PM
        break;
      case 'dd-MMM-yyyy EEEE HH:mm':
        time = DateFormat(timePattern).format(date); // Örnek: 14:30 veya 2:30 PM
        weekday = DateFormat('EEE').format(date); // Örnek: Perşembe
        break;
      default:
        break; // Varsayılan: Gün ve Ay
    }

    // Yan yana gösterim için widget listesi
    List<Widget> dateWidgets = [
      Baseline(
        baseline: 24, // Baz çizgisini 24 piksel olarak ayarla
        baselineType: TextBaseline.alphabetic,
        child: Text(
          day,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      const SizedBox(width: 6), // Gün ile Ay arasına boşluk
      Baseline(
        baseline: 24, // Baz çizgisini 24 piksel olarak ayarla
        baselineType: TextBaseline.alphabetic,
        child: Text(
          month,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ),
    ];

    if (weekday.isNotEmpty) {
      dateWidgets.add(const SizedBox(width: 6)); // Ay ile Haftanın Günü arasına boşluk
      dateWidgets.add(
        Baseline(
          baseline: 24,
          baselineType: TextBaseline.alphabetic,
          child: Text(
            weekday,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    if (time.isNotEmpty) {
      dateWidgets.add(const SizedBox(width: 6)); // Haftanın Günü ile Saat arasına boşluk
      dateWidgets.add(
        Baseline(
          baseline: 24,
          baselineType: TextBaseline.alphabetic,
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return dateWidgets;
  }

  /// Sadece saat formatı
  String _formatOnlyTime(DateTime date, String timeFormat) {
    final timePattern = timeFormat == '24-hour' ? 'HH:mm' : 'hh:mm a';
    return DateFormat(timePattern).format(date);
  }

  /// Tarihi belirli bir formata göre formatlar
  String _formatDateForDisplay(DateTime date, String dateFormat, String timeFormat) {
    // Saat biçimini belirle
    final timePattern = timeFormat == '24-hour' ? 'HH:mm' : 'hh:mm a';

    switch (dateFormat) {
      case 'dd-MMM-yyyy':
        return DateFormat('dd MMM').format(date); // Örnek: 24 Nis
      case 'dd-MMM-yyyy HH:mm':
        return DateFormat('dd MMM $timePattern').format(date); // Örnek: 24 Nis 14:30 veya 24 Nis 2:30 PM
      case 'dd-MMM-yyyy EEEE HH:mm':
        return DateFormat('dd MMM EEE $timePattern').format(date); // Örnek: 24 Nis Perşembe 14:30 veya 24 Nis Perşembe 2:30 PM
      default:
        return DateFormat('dd MMM').format(date); // Varsayılan format: 24 Nis
    }
  }
}