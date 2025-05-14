import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pattern_lock/pattern_lock.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:deardiary/features/settings/services/fingerprint_service.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';

class PatternLockVerifyPage extends StatefulWidget {
  const PatternLockVerifyPage({super.key});

  @override
  State<PatternLockVerifyPage> createState() => _PatternLockVerifyPageState();
}

class _PatternLockVerifyPageState extends State<PatternLockVerifyPage> {
  String displayMessage = "Lütfen şifrenizi giriniz"; // Varsayılan mesaj
  bool isFingerprintEnabled = false; // Parmak izi toggle durumu
  int? dimension; // Dinamik desen boyutu
  bool isLoading = true; // Ekran yükleme durumu

  final FingerprintService _fingerprintService =
      FingerprintService(); // Parmak izi servisi

  @override
  void initState() {
    super.initState();
    _initializeLockSettings(); // Günlük kilidi ve parmak izi ayarlarını yükle
  }

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

      final patternDimension = await lockManager.getPatternDimension();

      setState(() {
        isFingerprintEnabled = isFingerprintActive && hasBiometric;
        dimension = patternDimension ?? 3; // Varsayılan 3x3
        displayMessage =
            isFingerprintEnabled
                ? "Kilit açma desenini çizin veya parmak izi kullanın"
                : "Kilit açmak için deseni çizin";
        isLoading = false; // Yükleme tamamlandı
      });

      if (isFingerprintEnabled) {
        // Parmak izi doğrulama otomatik olarak başlatılır
        _authenticateWithFingerprint();
      }
    } catch (e) {
      setState(() {
        displayMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";
        isLoading = false;
      });
      print("Error initializing lock settings: $e");
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      print("Fingerprint authentication is not supported on this platform.");
      return;
    }

    try {
      final isAuthenticated =
          await _fingerprintService.authenticateWithFingerprint();

      if (isAuthenticated) {
        setState(() {
          displayMessage = "Parmak izi doğrulandı";
        });
        Future.delayed(const Duration(seconds: 1), () {
          NavigationService().navigateTo('/'); // Ana sayfaya yönlendir
        });
      } else {
        setState(() {
          displayMessage = "Parmak izi doğrulama başarısız!";
        });
      }
    } catch (e) {
      setState(() {
        displayMessage = "Parmak izi doğrulama sırasında bir hata oluştu.";
      });
      print("Error during fingerprint authentication: $e");
    }
  }

  Future<void> _handlePatternInput(List<int> pattern) async {
    final lockManager = LockManager();
    final isValid = await lockManager.verifyPattern(pattern);

    if (isValid) {
      setState(() {
        displayMessage = "Şifre doğrulandı";
        lockManager.isAuthenticated = true;
      });

      Navigator.pop(context);
    } else {
      setState(() {
        displayMessage = "Hatalı şifre! Tekrar deneyin.";
      });
    }
  }

  // Diğer importlar

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (isLoading) {
      // Ekran yüklenirken bir yükleme göstergesi göster
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
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
            // Karartılmış overlay
            Container(color: Colors.black.withOpacity(0.90)),
            // İçerik
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1, // Responsive yatay padding
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // Daha iyi denge
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Üstteki mesaj
                    Text(
                      displayMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            displayMessage.contains("Hatalı") ||
                                    displayMessage.contains("başarısız")
                                ? Colors.red
                                : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Desen kilidi
                    Flexible(
                      child: Center(
                        child: PatternLock(
                          relativePadding: 1.0,
                          pointRadius:
                              size.width * 0.02, // Dinamik nokta boyutu
                          selectedColor: Colors.blue,
                          notSelectedColor: Colors.grey,
                          dimension: dimension ?? 3, // Dinamik desen boyutu
                          onInputComplete: _handlePatternInput,
                        ),
                      ),
                    ),
                    // Alt kısımdaki bölümler
                    Column(
                      children: [
                        if (isFingerprintEnabled) ...[
                          GestureDetector(
                            onTap: _authenticateWithFingerprint,
                            child: Icon(
                              Icons.fingerprint,
                              size: size.width * 0.15,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                        TextButton(
                          onPressed: () {
                            print("Şifremi Unuttum butonuna basıldı");
                            NavigationService().navigateTo('/forgotPassword');
                          },
                          child: const Text(
                            "Şifremi Unuttum",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
