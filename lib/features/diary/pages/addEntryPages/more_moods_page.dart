import 'package:flutter/material.dart';

class MoreMoodsPage extends StatelessWidget {
  const MoreMoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodGroups = [
      ["😺", "😸", "😹", "😻", "😼"],
      ["🐤", "🐥", "🐣", "🐔", "🦆"],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daha Fazla Ruh Hali"),
      ),
      body: Column(
        children: moodGroups
            .map((group) => Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: group
                      .map((mood) => GestureDetector(
                            onTap: () {
                              Navigator.pop(context, mood); // Geri dön ve seçimi gönder
                            },
                            child: Text(
                              mood,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }
}