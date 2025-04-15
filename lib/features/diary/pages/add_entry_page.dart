import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';

class AddEntryPage extends StatefulWidget {
  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedMood;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  void _saveEntry() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      final newEntry = DiaryEntry(
        title: title,
        content: content,
        date: selectedDate,
        mood: selectedMood,
      );

      // Günlüğü Provider üzerinden ekliyoruz
      final provider = Provider.of<DiaryProvider>(context, listen: false);
      provider.addEntry(newEntry);

      Navigator.pop(context); // Ana sayfaya geri dön
    } else {
      // Uyarı mesajı göstermek için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başlık ve içerik boş bırakılamaz!')),
      );
    }
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
        leading: BackButton(),
        title: Text('Yeni Günlük'),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              "Kaydet",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _selectDate,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.emoji_emotions),
                  onSelected: (String mood) {
                    setState(() {
                      selectedMood = mood;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(value: "😊", child: Text("😊 Mutlu")),
                    PopupMenuItem(value: "😢", child: Text("😢 Üzgün")),
                    PopupMenuItem(value: "😠", child: Text("😠 Sinirli")),
                    PopupMenuItem(value: "😌", child: Text("😌 Huzurlu")),
                    PopupMenuItem(value: "😴", child: Text("😴 Yorgun")),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Başlık giriniz',
                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                border: InputBorder.none,
              ),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
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