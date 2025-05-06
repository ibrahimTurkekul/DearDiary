import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiaryLockPage extends StatefulWidget {
  const DiaryLockPage({super.key});

  @override
  State<DiaryLockPage> createState() => _DiaryLockPageState();
}

class _DiaryLockPageState extends State<DiaryLockPage> {
  bool isDiaryLockEnabled = false;
  bool isFingerprintEnabled = false;
  bool hasExistingLock = false; // Cihazda kayıtlı bir şifre olup olmadığını kontrol eder

  @override
  void initState() {
    super.initState();
    _checkExistingLock(); // Cihazda kayıtlı bir şifre var mı kontrol et
  }

  Future<void> _checkExistingLock() async {
    final lockManager = LockManager();

    // Gerçek kullanıcı şifrelerini kontrol et
    final hasPattern = await lockManager.isPatternSet(); // Kayıtlı bir desen var mı kontrol edilir
    final hasPin = await lockManager.isPinSet(); // Kayıtlı bir PIN var mı kontrol edilir

    setState(() {
      hasExistingLock = hasPattern || hasPin;
      isDiaryLockEnabled = hasExistingLock; // Mevcut şifre varsa toggle etkin
    });
  }

  Future<void> _onDiaryLockToggleChanged(bool value) async {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    if (value) {
      if (!hasExistingLock) {
        // Şifre yoksa kullanıcıyı desen belirleme sürecine yönlendir
        await navigationService.navigateTo('/patternLockSetup');
        await _checkExistingLock(); // Şifre oluşturulduysa güncelle
      }
    } else {
      // Günlük kilidi kapatıldığında
      setState(() {
        isDiaryLockEnabled = false;
        isFingerprintEnabled = false; // Parmak izi kilidi de devre dışı
      });

      final lockManager = LockManager();
      await lockManager.deactivateDiaryLock(); // Günlük kilidini devre dışı bırak
    }

    // Toggle durumunu güncelle
    setState(() {
      isDiaryLockEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Günlük Kilidi Ayarları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Günlük kilidi toggle
            SwitchListTile(
              title: const Text("Günlük Kilidi"),
              subtitle: const Text("Günlüğünüzü korumak için bir kilit ayarlayın."),
              value: isDiaryLockEnabled,
              onChanged: (value) async {
                await _onDiaryLockToggleChanged(value);
              },
            ),
            // Şifreyi belirle
            ListTile(
              title: const Text("Şifreyi Belirle"),
              subtitle: const Text("Şifrenizi ayarlayın veya değiştirin."),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/patternLockSetup'); // Desen belirleme sayfasına git
              },
            ),
            // Güvenlik sorusu ayarla
            ListTile(
              title: const Text("Güvenlik Sorusunu Ayarla"),
              subtitle: const Text("Şifrenizi geri almak için kullanılacaktır."),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/securityQuestionSetup'); // Güvenlik sorusu sayfasına git
              },
            ),
            // E-posta adresi ayarla
            ListTile(
              title: const Text("E-posta Adresini Ayarla"),
              subtitle: const Text("Geri alma işlemleri için e-posta adresinizi ayarlayın."),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/emailSetupPage'); // E-posta adresi ayarlama sayfasına git
              },
            ),
            // Parmak izi toggle
            SwitchListTile(
              title: const Text("Parmak İzini Etkinleştir"),
              subtitle: const Text("Parmak izinizi kullanarak günlük kilidini açın."),
              value: isFingerprintEnabled,
              onChanged: isDiaryLockEnabled
                  ? (value) {
                      setState(() {
                        isFingerprintEnabled = value;
                      });
                    }
                  : null, // Günlük kilidi kapalıysa pasif
            ),
          ],
        ),
      ),
    );
  }
}