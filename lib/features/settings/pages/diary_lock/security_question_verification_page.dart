import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';

class SecurityQuestionVerificationPage extends StatefulWidget {
  final String? question; // Kullanıcının kaydettiği güvenlik sorusu

  const SecurityQuestionVerificationPage({super.key, this.question});

  @override
  State<SecurityQuestionVerificationPage> createState() =>
      _SecurityQuestionVerificationPageState();
}

class _SecurityQuestionVerificationPageState
    extends State<SecurityQuestionVerificationPage> {
  final TextEditingController _answerController = TextEditingController();
  bool isLoading = true; // Veriler yüklenme durumunda mı?
  String? lockType; // Aktif kilit türü (PIN veya desen)
  bool isPinSet = false; // PIN kayıtlı mı
  bool isPatternSet = false; // Desen kilidi kayıtlı mı

  @override
  void initState() {
    super.initState();
    _loadData(); // LockManager'dan verileri yükle
  }

  Future<void> _loadData() async {
    final lockManager = LockManager();

    try {
      // Kilit türü ve kayıt durumlarını kontrol et
      final activeLockType = await lockManager.getActiveLockType();
      final pinExists = await lockManager.isPinSet();
      final patternExists = await lockManager.isPatternSet();

      // Debug logları
      print("Kilit Türü: $activeLockType");
      print("PIN Kayıtlı mı?: $pinExists");
      print("Desen Kayıtlı mı?: $patternExists");

      setState(() {
        lockType = activeLockType ?? "Belirtilmemiş"; // Null kontrolü
        isPinSet = pinExists;
        isPatternSet = patternExists;
        isLoading = false; // Yükleme tamamlandı
      });
    } catch (e) {
      print("Veri yükleme sırasında bir hata oluştu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Cevabı doğrula
  Future<void> _verifyAnswer() async {
    final lockManager = LockManager();
    final userAnswer = _answerController.text.trim();
    final navigationService = NavigationService();

    try {
      // Kullanıcının cevabını doğrula
      final isCorrect = await lockManager.verifySecurityAnswer(userAnswer);

      if (isCorrect) {
        // Doğru cevap, kilit türüne göre işlem yap
        if (lockType == "pin" && isPinSet) {
          // PIN kayıtlı ise PIN'i göster
          navigationService.navigateTo('/patternLockSetup');
        } else if (lockType == "pattern" && isPatternSet) {
          // Desen kilidi kayıtlı ise PNG resmini göster
          navigationService.navigateTo('/patternLockSetup');
        } else {
          // Hiçbir kilit türü bulunamadıysa mesaj göster
          _showPopup("Bilgi", "Kayıtlı bir şifre veya desen bulunamadı.");
        }
      } else {
        // Yanlış cevap mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yanlış cevap girdiniz!")),
        );
      }
    } catch (e) {
      print("Cevap doğrulama sırasında bir hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu. Lütfen tekrar deneyin.")),
      );
    }
  }

  // Popup içinde yazı göster
  void _showPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }

  // Popup içinde resim göster
  void _showPopupWithImage(String title, String imagePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Image.asset(imagePath),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Güvenlik Sorusu Doğrulama"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          // Karartılmış overlay
          Container(
            color: Colors.black.withOpacity(0.90),
          ),
          // İçerik
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.question ?? "Güvenlik sorusu bulunamadı.",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _answerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Cevabınızı yazınız",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verifyAnswer,
                    child: const Text("ONAYLA"),
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