import 'package:flutter/material.dart';

class BackupOptionsPage extends StatelessWidget {
  const BackupOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yedekleme Seçenekleri'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Verileri Yedekle'),
            trailing: const Icon(Icons.cloud_upload),
            onTap: () {
              // TODO: Implement backup functionality
            },
          ),
          ListTile(
            title: const Text('Verileri Geri Yükle'),
            trailing: const Icon(Icons.cloud_download),
            onTap: () {
              // TODO: Implement restore functionality
            },
          ),
        ],
      ),
    );
  }
}