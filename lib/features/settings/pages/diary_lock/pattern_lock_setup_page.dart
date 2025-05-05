import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import '../../services/storage_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PatternLockSetupPage extends StatefulWidget {
  const PatternLockSetupPage({super.key});

  @override
  State<PatternLockSetupPage> createState() => _PatternLockSetupPageState();
}

class _PatternLockSetupPageState extends State<PatternLockSetupPage> {
  List<int>? firstPattern;
  final storageService = StorageService();
  int dimension = 3; // Varsayılan olarak 3x3 desen
  String displayMessage = "Kilit açma deseni çizin"; // Dinamik mesaj

  String _generateHash(List<int> pattern) {
    final bytes = utf8.encode(pattern.join());
    return sha256.convert(bytes).toString();
  }

  void _handlePatternInput(List<int> pattern) {
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
        final hash = _generateHash(pattern);
        storageService.savePatternHash(hash);
        setState(() {
          displayMessage = "Desen başarıyla kaydedildi";
        });
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Image.asset(
                'assets/themes/light.png', // Uygulama logosu
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                'DearDiary',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
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
            color: Colors.black.withValues(alpha: 0.95), // Siyaha yakın ton
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
                        onTap: () {
                          setState(() {
                            dimension = dimension == 3 ? 5 : 3; // Desen boyutu değişimi
                          });
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
    );
  }
}