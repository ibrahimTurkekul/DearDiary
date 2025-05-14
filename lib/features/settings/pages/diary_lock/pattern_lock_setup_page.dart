import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:provider/provider.dart';
import '../../services/lock_manager.dart'; // LockManager import edildi

class PatternLockSetupPage extends StatefulWidget {
  const PatternLockSetupPage({super.key, required lockType});

  @override
  State<PatternLockSetupPage> createState() => _PatternLockSetupPageState();
}

class _PatternLockSetupPageState extends State<PatternLockSetupPage> {
  List<int>? firstPattern;
  int dimension = 3; // Varsayılan olarak 3x3 desen
  String displayMessage = "Kilit açma deseni çizin"; // Dinamik mesaj

  @override
  void initState() {
    super.initState();
    _loadPatternDimension(); // Kaydedilen dimension bilgisini yükle
  }

  Future<void> _loadPatternDimension() async {
    final lockManager = LockManager();
    final savedDimension = await lockManager.getPatternDimension();
    setState(() {
      dimension = savedDimension ?? 3; // Eğer kaydedilmemişse varsayılan olarak 3x3
    });
  }

  Future<void> _savePatternDimension(int newDimension) async {
    final lockManager = LockManager();
    await lockManager.savePatternDimension(newDimension); // Yeni dimension bilgisini kaydet
  }

  // Kullanıcı ilerlemeden çıkarsa toggle durumunu kontrol et
  Future<void> _handleExit() async {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    // Kullanıcıdan çıkış onayı alın ya da toggle'ı pasif hale getir
    final shouldDeactivateToggle = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Şifre Kurulumu İptal Edilsin mi?"),
        content: const Text(
          "Kurulum işlemini tamamlamadan çıkarsanız günlük kilidi devre dışı bırakılacaktır.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Çıkışı iptal et
            child: const Text("Hayır"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Çıkışı kabul et
            child: const Text("Evet"),
          ),
        ],
      ),
    );

    if (shouldDeactivateToggle ?? false) {
      final lockManager = LockManager();
      await lockManager.clearAll();
      // Günlük kilidi toggle'ını pasif hale getir ve geri dön
      navigationService.navigateTo('/diaryLock');
    }
  }

  void _handlePatternInput(List<int> pattern) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (pattern.length < 4) {
      setState(() {
        displayMessage = "En az dört noktayı birleştir";
      });
      return;
    }
    if (firstPattern == null) {
      setState(() {
        firstPattern = pattern;
        displayMessage = "Deseni tekrar girin";
      });
    } else {
      if (firstPattern!.join() == pattern.join()) {
        setState(() {
          displayMessage = "Desen başarıyla kaydedildi";
        });
        Future.delayed(const Duration(seconds: 1), () {
          navigationService.navigateTo(
            '/securityQuestionSetup',
            arguments: {
              'lockType': 'pattern', // Desen kilidi türü
              'pattern': pattern,
            },
          ); // Güvenlik sorusu sayfasına yönlendirme
        });
      } else {
        setState(() {
          displayMessage = "Desenler eşleşmiyor!";
          firstPattern = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutları
    final double pointRadius = size.width * 0.02; // Nokta boyutu

    return WillPopScope(
      onWillPop: () async {
        await _handleExit();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async => await _handleExit(),
          ),
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
              color: Colors.black.withValues(alpha:0.90), // Siyaha yakın ton
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1, // Responsive yatay padding
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dinamik bilgilendirme mesajı
                    Text(
                      displayMessage,
                      style: TextStyle(
                        color: displayMessage == "En az dört noktayı birleştir" ||
                                displayMessage == "Desenler eşleşmiyor!"
                            ? Colors.red
                            : Colors.white,
                        fontSize: size.width * 0.05, // Responsive yazı boyutu
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.05), // Responsive boşluk
                    // Pattern Lock
                    AspectRatio(
                      aspectRatio: 1, // Kare şeklinde alan
                      child: PatternLock(
                        selectedColor: Colors.white, // Seçili nokta rengi
                        notSelectedColor: Colors.grey, // Seçilmemiş nokta rengi
                        pointRadius: pointRadius,
                        fillPoints: true,
                        showInput: true,
                        dimension: dimension,
                        onInputComplete: _handlePatternInput,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03), // Responsive boşluk
                    // Alt yazılar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final newDimension = dimension == 3 ? 5 : 3;
                            setState(() {
                              dimension = newDimension; // Desen boyutu değişimi
                            });
                            await _savePatternDimension(newDimension); // Yeni boyutu kaydet
                          },
                          child: Text(
                            dimension == 3 ? "Daha Güçlü Desen" : "Daha Kolay Desen",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: size.width * 0.04, // Responsive yazı boyutu
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/pinLockSetup'); // PIN kilidi sayfasına yönlendirme
                          },
                          child: Text(
                            "PIN Kilidi Kullan",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontSize: size.width * 0.04, // Responsive yazı boyutu
                            ),
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