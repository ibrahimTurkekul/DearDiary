import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../diary/models/diary_entry.dart';
import '../diary/providers/diary_provider.dart';
import '../../shared/utils/navigation_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month; // Varsayılan format
  Map<DateTime, List<DiaryEntry>> _groupedEntries = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _groupEntries(); // Günlükleri her build çağrısında gruplandır
  }

  void _groupEntries() {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final entries = provider.entries;

    _groupedEntries = {};
    for (final entry in entries) {
      final DateTime entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (_groupedEntries[entryDate] == null) {
        _groupedEntries[entryDate] = [];
      }
      _groupedEntries[entryDate]!.add(entry);
    }
    setState(() {}); // Güncellemeleri yansıt
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    final entries = _groupedEntries[DateTime(day.year, day.month, day.day)] ?? [];
    return entries.reversed.toList(); // Günlükleri ters sırada döndür
  }

  String _getMoodEmoji(List<DiaryEntry> entries) {
    if (entries.isNotEmpty) {
      final latestEntry = entries.last; // Son eklenen günlüğün ruh hali
      return latestEntry.mood ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryProvider>(context);
    final selectedDayEntries = _getEntriesForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: _calendarFormat, // Varsayılan format
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month', // Aylık görünüm
                CalendarFormat.twoWeeks: '2 Weeks', // 2 haftalık görünüm
                CalendarFormat.week: 'Week', // Haftalık görünüm
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final entries = _getEntriesForDay(day); // O güne ait günlükler
                  final emoji = _getMoodEmoji(entries); // Son eklenen günlüğün emojisi
                  return Center(
                    child: Text(
                      emoji.isNotEmpty ? emoji : '${day.day}', // Emojiyi göster veya günü yaz
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // Seçilen günü güncelle
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format; // Takvim biçimini güncelle
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${_selectedDay.day} ${_getMonthName(_selectedDay.month)} ${_selectedDay.year}, ${_getWeekdayName(_selectedDay.weekday)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            selectedDayEntries.isEmpty
                ? const Center(
                    child: Text(
                      "Bu günde günlük yok. Şimdi yaz!",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedDayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = selectedDayEntries[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            final correctIndex = provider.entries.indexOf(entry); // Doğru index hesabı
                            NavigationService().navigateToPreview(correctIndex);
                          },
                          leading: Text(
                            '${entry.date.hour.toString().padLeft(2, '0')}:${entry.date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          title: Text(entry.title),
                          subtitle: Text(
                            '${entry.content.split('.').first}...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            entry.mood ?? '',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NavigationService().navigateToAddEntry(date: _selectedDay);
          _groupEntries(); // Yeni günlük eklendiğinde tabloyu yeniden grupla
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return weekdays[weekday - 1];
  }
}