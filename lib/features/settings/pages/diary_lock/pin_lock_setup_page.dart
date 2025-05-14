import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/lock_manager.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';

class PinLockSetupPage extends StatelessWidget {
  final String? lockType; // lockType argümanı
  final StorageService storageService = StorageService();
  final LockManager lockManager = LockManager();

  PinLockSetupPage({super.key, required this.lockType});

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("PIN Kilidi Ayarla"),
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/themes/light.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Siyah transparan overlay
          Container(
            color: Colors.black.withOpacity(0.90), // Siyaha yakın karartma
          ),
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ScreenLock.create(
                      digits: 6,
                      title: const Text(
                        "PIN'inizi Ayarlayın",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      confirmTitle: const Text(
                        "PIN'i Onaylayın",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      config: const ScreenLockConfig(
                        backgroundColor: Colors.transparent,
                      ),
                      secretsConfig: SecretsConfig(
                        spacing: 15,
                        padding: const EdgeInsets.all(40),
                        secretConfig: SecretConfig(
                          borderColor: Colors.redAccent,
                          borderSize: 2.0,
                          disabledColor: Colors.grey,
                          enabledColor: Colors.redAccent,
                         
                        ),
                      ),
                      
                      cancelButton: const Icon(Icons.close),
                      deleteButton: const Icon(Icons.delete),
                      footer: Center(
                        child: TextButton(
                          onPressed: () {
                            // Şifremi Unuttum butonuna basıldığında yapılacak işlemler
                            NavigationService().navigateTo(
                                '/patternLockSetup',
                                arguments: {'lockType': 'pattern'}, // Desen kilidi için argüman aktarımı
                              );
                            print("Şifremi Unuttum butonuna basıldı");
                            // "Şifremi Unuttum" sayfasına yönlendirme işlemi burada yapılabilir
                          },
                          child: const Text(
                            'Desen Kilidi Kullan',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ),
                      ),
                      onConfirmed: (pin) async {
                        await storageService.savePin(pin); // PIN'i kaydet
                        await lockManager.setActiveLockType('pin'); // Aktif kilit türünü kaydet
                        navigationService.navigateTo(
                          '/securityQuestionSetup',
                          arguments: {
                            'lockType': 'pin',
                            'pin': pin, // Kaydedilen PIN aktarılıyor
                          },
                        );
                      },
                    ),
                  ),
                 // SizedBox(height: size.height * 0.05), // Boşluk
                ],
              ),
          ),
        ],
      ),
    );
  }
}