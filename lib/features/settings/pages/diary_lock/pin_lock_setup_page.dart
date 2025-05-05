import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import '../../services/storage_service.dart';

class PinLockSetupPage extends StatelessWidget {
  final storageService = StorageService();

  PinLockSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PIN Kilidi Ayarla"),
      ),
      body: ScreenLock.create(
        onConfirmed: (pin) {
          storageService.savePin(pin);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PIN başarıyla kaydedildi")),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}