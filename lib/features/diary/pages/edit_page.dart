import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';

class EditPage extends StatefulWidget {
  final DiaryEntry entry;

  const EditPage({Key? key, required this.entry}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late DateTime selectedDate;
  String? selectedMood;
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    // Mevcut günlüğün verilerini başlatıyoruz
    selectedDate = widget.entry.date;
    selectedMood = widget.entry.mood;
    titleController = TextEditingController(text: widget.entry.title);
    contentController = TextEditingController(text: widget.entry.content);
  }

  void _updateEntry() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      // Günlüğü güncelle
      final updatedEntry = DiaryEntry(
        title: title,
        content: content,
        date: selectedDate,
        mood: selectedMood,
      );

      // Günlüğü Provider üzerinden güncelle
      final provider = Provider.of<DiaryProvider>(context, listen: false);
      provider.updateEntry(widget.entry, updatedEntry);

      // Güncellenmiş veriyi geri döndür
      Navigator.pop(context, updatedEntry);
    } else {
      // Eğer başlık veya içerik boşsa, kullanıcıya bir uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık ve içerik boş bırakılamaz!')),
      );
    }
  }

  void _selectDate() async {
    // Tarih seçici ile tarih seçimi
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
        title: const Text('Günlüğü Düzenle'),
        actions: [
          // Kaydet Butonu
          TextButton(
            onPressed: _updateEntry,
            child: const Text("Kaydet", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tarih seçici
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
                // Duygu durumu seçici
                PopupMenuButton<String>(
                  icon: const Icon(Icons.emoji_emotions),
                  onSelected: (String mood) {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                          value: "😊",
                          child: Text("😊 Mutlu"),
                        ),
                        const PopupMenuItem(
                          value: "😢",
                          child: Text("😢 Üzgün"),
                        ),
                        const PopupMenuItem(
                          value: "😠",
                          child: Text("😠 Sinirli"),
                        ),
                        const PopupMenuItem(
                          value: "😌",
                          child: Text("😌 Huzurlu"),
                        ),
                        const PopupMenuItem(
                          value: "😴",
                          child: Text("😴 Yorgun"),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Başlık alanı
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Başlık giriniz',
                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            // İçerik alanı
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
    );
  }
}
