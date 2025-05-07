import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:provider/provider.dart';

class PatternLockVerifyPage extends StatefulWidget {
  const PatternLockVerifyPage({super.key});

  @override
  State<PatternLockVerifyPage> createState() => _PatternLockVerifyPageState();
}

class _PatternLockVerifyPageState extends State<PatternLockVerifyPage> {
  String displayMessage =
      "Lütfen şifrenizi giriniz"; // Kullanıcıya gösterilecek dinamik mesaj

  Future<void> _handlePatternInput(List<int> pattern) async {
    final lockManager = LockManager();
    final isValid = await lockManager.verifyPattern(pattern); // Şifre doğrulama

    if (isValid) {
      setState(() {
        displayMessage = "Şifre doğrulandı";
      });
      Future.delayed(const Duration(seconds: 1), () {
        NavigationService().navigateTo('/'); // Ana sayfaya yönlendir
      });
    } else {
      setState(() {
        displayMessage = "Hatalı şifre! Tekrar deneyin.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutları

    return Scaffold(
      appBar: AppBar(title: const Text("Şifre Doğrulama")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayMessage,
              style: TextStyle(
                color:
                    displayMessage == "Hatalı şifre! Tekrar deneyin."
                        ? Colors.red
                        : Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            AspectRatio(
              aspectRatio: 1,
              child: PatternLock(
                selectedColor: Colors.blue,
                notSelectedColor: Colors.grey,
                dimension: 3,
                onInputComplete: _handlePatternInput,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
