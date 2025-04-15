import 'package:hive/hive.dart';

part 'diary_entry.g.dart'; // Hive için oluşturulacak adapter dosyası

@HiveType(typeId: 0) // Her model için benzersiz bir typeId verin
class DiaryEntry {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? mood;

  DiaryEntry({
    required this.title,
    required this.content,
    required this.date,
    this.mood,
  });
}