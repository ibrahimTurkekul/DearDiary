import 'package:flutter/material.dart';

class MoodStylePage extends StatelessWidget {
  const MoodStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    final moodStyles = ['Default', 'Minimalist', 'Detailed'];
    String selectedStyle = moodStyles[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruh Hali Tarzı'),
      ),
      body: ListView.builder(
        itemCount: moodStyles.length,
        itemBuilder: (context, index) {
          final style = moodStyles[index];
          return RadioListTile<String>(
            title: Text(style),
            value: style,
            groupValue: selectedStyle,
            onChanged: (value) {
              if (value != null) {
                selectedStyle = value;
                // TODO: Update mood style in settings
              }
            },
          );
        },
      ),
    );
  }
}