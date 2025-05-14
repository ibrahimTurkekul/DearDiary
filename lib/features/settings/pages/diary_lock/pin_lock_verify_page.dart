import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:deardiary/features/settings/services/fingerprint_service.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';

class PinLockVerifyPage extends StatefulWidget {
  const PinLockVerifyPage({super.key});

  @override
  State<PinLockVerifyPage> createState() => _PinLockVerifyPageState();
}

class _PinLockVerifyPageState extends State<PinLockVerifyPage> {
  bool isLoading = true; // Yükleme durumu
  bool isFingerprintEnabled = false; // Parmak izi durumu
  final FingerprintService _fingerprintService =
      FingerprintService(); // Parmak izi doğrulama servisi

  @override
  void initState() {
    super.initState();
    _initializeLockSettings();
  }

  /// Parmak izi ve PIN doğrulama ayarlarını başlatır
  Future<void> _initializeLockSettings() async {
    try {
      final lockManager = LockManager();

      // Parmak izi yalnızca mobil platformlarda kontrol edilir
      final isFingerprintActive =
          (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
              ? await lockManager.isFingerprintEnabled()
              : false;

      final hasBiometric =
          (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
              ? await _fingerprintService.isBiometricAvailable()
              : false;

      setState(() {
        isFingerprintEnabled = isFingerprintActive && hasBiometric;
        isLoading = false; // Yükleme tamamlandı
      });

      if (isFingerprintEnabled) {
        // Parmak izi doğrulama otomatik olarak başlatılır
        _authenticateWithFingerprint();
      } else {
        // PIN doğrulama ekranını göster
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPinLockScreen();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error initializing lock settings: $e");
    }
  }

  /// Parmak izi doğrulama işlemi
  Future<void> _authenticateWithFingerprint() async {
    final lockManager = LockManager();
    try {
      final isAuthenticated =
          await _fingerprintService.authenticateWithFingerprint();

      if (isAuthenticated) {
        lockManager.isAuthenticated = true;
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        // Parmak izi başarısız olursa PIN ekranını göster
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPinLockScreen();
        });
      }
    } catch (e) {
      print("Error during fingerprint authentication: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPinLockScreen(); // Hata durumunda PIN ekranını göster
      });
    }
  }

  /// PIN doğrulama ekranını göster
  void _showPinLockScreen() {
    final lockManager = LockManager();
    screenLock(
      context: context,
      correctString:
          '000000', // Burada doğru PIN dinamik olarak kontrol edilecek
      canCancel: false, // Kullanıcı iptal edemez
      title: const Text(
        "PIN'inizi giriniz",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      onValidate: (input) async {
        final isValid = await lockManager.verifyPin(input);
        return isValid; // PIN doğrulama sonucu
      },
      onUnlocked: () {
        // PIN doğrulama başarılı olduğunda bir önceki sayfaya yönlendir
        lockManager.isAuthenticated = true;
        Navigator.pop(context);
        Navigator.pop(context);
      },
      cancelButton: const Text('İptal', style: TextStyle(color: Colors.white)),
      footer: Center(
        child: TextButton(
          onPressed: () {
            // Şifremi Unuttum butonuna basıldığında yapılacak işlemler
            NavigationService().navigateTo('/forgotPassword');
            print("Şifremi Unuttum butonuna basıldı");
            // "Şifremi Unuttum" sayfasına yönlendirme işlemi burada yapılabilir
          },
          child: const Text(
            'Şifremi Unuttum',
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
      ),
      config: const ScreenLockConfig(backgroundColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Yükleme sırasında gösterilecek ekran
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Boş bir ekran döndür, çünkü PIN doğrulama ekranı zaten dialog olarak açılıyor
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/themes/light.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.90)),
        ],
      ),
    );
  }
}
