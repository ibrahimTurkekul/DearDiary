import 'package:flutter/material.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = ['Türkçe', 'English', 'Español'];
    String selectedLanguage = languages[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dil Seçenekleri'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          return RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: selectedLanguage,
            onChanged: (value) {
              if (value != null) {
                selectedLanguage = value;
                // TODO: Update language in settings
              }
            },
          );
        },
      ),
    );
  }
}