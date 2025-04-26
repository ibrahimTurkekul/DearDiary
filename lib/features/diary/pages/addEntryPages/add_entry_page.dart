import 'package:deardiary/features/diary/pages/addEntryPages/more_moods_page.dart';
import 'package:deardiary/features/settings/services/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:deardiary/features/diary/models/diary_entry.dart';
import 'package:deardiary/features/diary/providers/diary_provider.dart';
import 'mood_popup.dart';
import 'entry_toolbar.dart';

class AddEntryPage extends StatefulWidget {
  final DateTime? date;
  const AddEntryPage({super.key, this.date});

  @override
  // ignore: library_private_types_in_public_api
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedMood = "😊"; // Varsayılan emoji

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date ?? DateTime.now();
    // Sayfa yüklendiğinde popup'ı göster
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    if (settingsManager.skipMoodSelection) {
      // Eğer Ruh Hali Seçimini Atla aktifse, varsayılan ruh halini seç
      selectedMood = "😊"; // Varsayılan ruh hali emojisi
    } else {
      // Eğer Ruh Hali Seçimini Atla aktif değilse, popup göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMoodPopup();
      });
    }
  }

  void _showMoodPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return MoodPopup(
          currentMood: selectedMood,
          onMoodSelected: (mood) {
            setState(() {
              selectedMood = mood;
            });
          },
          onMorePressed: _navigateToMoreMoods,
        );
      },
    );
  }

  void _navigateToMoreMoods() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MoreMoodsPage()),
    );
  }

  void _saveEntry() {
    final title = titleController.text.trim().isNotEmpty
        ? titleController.text.trim()
        : "Başlıksız"; // Varsayılan başlık
    final content = contentController.text.trim().isNotEmpty
        ? contentController.text.trim()
        : "İçerik yok"; // Varsayılan içerik

    final newEntry = DiaryEntry(
      title: title,
      content: content,
      date: selectedDate,
      mood: selectedMood,
    );

    final provider = Provider.of<DiaryProvider>(context, listen: false);
    provider.addEntry(newEntry);

    Navigator.pop(context); // Ana sayfaya geri dön
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Yeni Günlük'),
        actions: [
          TextButton(
            onPressed: () async{
              _saveEntry();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Günlük Kaydedildi"),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating, // Snackbar yukarıda "float" edecek
                margin: const EdgeInsets.all(16), // Kenarlardan boşluk bırak
              ),
            );}, 
            child: const Text(
              "Kaydet",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Üst Kısım: Tarih ve Ruh Hali
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _selectDate,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showMoodPopup,
                  child: Row(
                    children: [
                      Text(
                        selectedMood ?? "😊",
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Orta Kısım: Başlık ve İçerik
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Başlık giriniz',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        hintText: 'Bugün neler oldu?',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Alt Araç Çubuğu
          const EntryToolbar(),
        ],
      ),
    );
  }
}