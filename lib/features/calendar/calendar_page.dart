import 'package:deardiary/features/diary/widgets/diary_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../diary/models/diary_entry.dart';
import '../diary/providers/diary_provider.dart';
import '../../shared/utils/navigation_service.dart';
import '../../features/settings/services/settings_manager.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<DiaryEntry>> _groupedEntries = {};
  StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.monday;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStartingDayOfWeek();
    _groupEntries();
  }

  void _updateStartingDayOfWeek() {
    final settingsManager = Provider.of<SettingsManager>(context);
    final firstDay = settingsManager.firstDayOfWeek ?? 'Pazartesi';

    setState(() {
      switch (firstDay) {
        case 'Pazar':
          _startingDayOfWeek = StartingDayOfWeek.sunday;
          break;
        case 'Cumartesi':
          _startingDayOfWeek = StartingDayOfWeek.saturday;
          break;
        default:
          _startingDayOfWeek = StartingDayOfWeek.monday;
      }
    });
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
    setState(() {});
  }

  List<DiaryEntry> _getEntriesForDay(DateTime day) {
    final entries = _groupedEntries[DateTime(day.year, day.month, day.day)] ?? [];
    return entries.reversed.toList();
  }

  String _getMoodEmoji(List<DiaryEntry> entries) {
    if (entries.isNotEmpty) {
      final latestEntry = entries.last;
      return latestEntry.mood ?? '';
    }
    return '';
  }

  void _showMonthYearPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _focusedDay) {
      setState(() {
        _focusedDay = DateTime(picked.year, picked.month, 1); // Ayın ilk günü
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiaryProvider>(context);
    final settingsManager = Provider.of<SettingsManager>(context);
    final selectedDayEntries = _getEntriesForDay(_selectedDay);

    // Zaman biçimi (24 saat veya 12 saat)
    final timeFormat = settingsManager.settings?.timeFormat ?? '24-hour';
    final is24HourFormat = timeFormat == '24-hour';

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
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: _startingDayOfWeek, // Haftanın ilk günü
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
                CalendarFormat.twoWeeks: '2 Weeks',
                CalendarFormat.week: 'Week',
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final entries = _getEntriesForDay(day);
                  final emoji = _getMoodEmoji(entries);

                  if (entries.isNotEmpty) {
                    if (settingsManager.showMoodInCalendar && emoji.isNotEmpty) {
                      return Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    } else {
                      return const Center(
                        child: Icon(Icons.send, size: 16, color: Colors.grey),
                      );
                    }
                  }
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
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
                      return DiaryEntryCard(
                        entry: entry,
                        onTap: () {
                          final correctIndex = provider.entries.indexOf(entry);
                          NavigationService().navigateToPreview(correctIndex);
                        },
                        displayOnlyTime: true, // Sadece saat göstermek için
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NavigationService().navigateToAddEntry(date: _selectedDay);
          _groupEntries();
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
