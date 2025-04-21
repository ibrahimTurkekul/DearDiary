import 'package:flutter/material.dart';

class EntryToolbar extends StatelessWidget {
  const EntryToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              // Yazı tipi değiştirme işlemi
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              // Resim ekleme işlemi
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              // Ses ekleme işlemi
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            onPressed: () {
              // Sticker veya emoji grubu ekleme
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_paint),
            onPressed: () {
              // Arka plan değiştirme işlemi
            },
          ),
        ],
      ),
    );
  }
}