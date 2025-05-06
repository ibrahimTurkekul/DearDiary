import 'package:flutter/material.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:provider/provider.dart';

class EmailSetupPage extends StatefulWidget {
  final String selectedQuestion; // Güvenlik sorusu
  final String securityAnswer; // Güvenlik sorusunun cevabı
  final List<int> pattern; // Desen kilidi

  const EmailSetupPage({
    super.key,
    required this.selectedQuestion,
    required this.securityAnswer,
    required this.pattern,
  });

  @override
  State<EmailSetupPage> createState() => _EmailSetupPageState();
}

class _EmailSetupPageState extends State<EmailSetupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();

  String buttonText = "Atla";
  String? emailError; // E-posta kontrolü için hata mesajı
  String? confirmEmailError; // Onay e-posta kontrolü için hata mesajı

  bool _isValidEmail(String email) {
    // E-posta formatını kontrol eden regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  void _showSkipPopup(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Artık doğrulama e-posta adresinize ihtiyacınız yok mu?"),
        content: const Text(
          "E-posta adresiniz yoksa şifrenizi doğrudan e-posta yoluyla geri alamazsınız.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Popup'ı kapat
              navigationService.navigateTo('/diaryLock'); // Günlük kilidi sayfasına git
            },
            child: const Text("Yine de Atla"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Popup'ı kapat
            },
            child: const Text("Anladım"),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final lockManager = LockManager();

    setState(() {
      emailError = _isValidEmail(emailController.text)
          ? null
          : "Geçerli bir e-posta adresi giriniz";
      confirmEmailError = emailController.text == confirmEmailController.text
          ? null
          : "E-posta adresleri eşleşmiyor";
    });

    if (emailError == null && confirmEmailError == null) {
      // Tüm verileri kaydet
      await lockManager.savePattern(widget.pattern);
      await lockManager.saveSecurityQuestion(
        widget.selectedQuestion,
        widget.securityAnswer,
      );
      await lockManager.saveEmail(emailController.text);
      await lockManager.activateDiaryLock(); // Günlük kilidini aktif hale getir

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bilgiler başarıyla kaydedildi")),
      );

      // Günlük kilidi sayfasına dön
      Future.delayed(const Duration(seconds: 1), () {
        navigationService.navigateTo('/diaryLock');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutlarını alır

    return Scaffold(
      appBar: AppBar(
        title: const Text("E-posta Adresini Ayarla"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Geri git
          },
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
            color: Colors.black.withOpacity(0.95), // Siyaha yakın ton
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1, // Responsive yatay padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.15), // Üst boşluk
                  const Text(
                    "Lütfen e-posta adresinizi, şifrenizi unuttuğunuzda geri alma e-postalarını alacak şekilde ayarlayınız.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.05), // Boşluk
                  const Text(
                    "E-posta adresin nedir?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: size.height * 0.02), // Boşluk
                  // E-posta alanı
                  TextField(
                    controller: emailController,
                    onChanged: (value) {
                      setState(() {
                        buttonText = (emailController.text.isNotEmpty &&
                                confirmEmailController.text.isNotEmpty)
                            ? "Onayla"
                            : "Atla";
                        emailError = null; // Kullanıcı giriş yaparken hata mesajı temizlenir
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "E-posta adresinizi buraya girin",
                      errorText: emailError, // Hata mesajı
                    ),
                  ),
                  SizedBox(height: size.height * 0.02), // Boşluk
                  // E-posta onay alanı
                  TextField(
                    controller: confirmEmailController,
                    onChanged: (value) {
                      setState(() {
                        buttonText = (emailController.text.isNotEmpty &&
                                confirmEmailController.text.isNotEmpty)
                            ? "Onayla"
                            : "Atla";
                        confirmEmailError =
                            null; // Kullanıcı giriş yaparken hata mesajı temizlenir
                      });
                    },
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Onaylamak için yeniden girin",
                      errorText: confirmEmailError, // Hata mesajı
                    ),
                  ),
                  SizedBox(height: size.height * 0.1), // Alt boşluk
                  // Atla/Onayla butonu
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (buttonText == "Atla") {
                          _showSkipPopup(context); // Atla popup'ını göster
                        } else {
                          _onConfirm(); // Onayla işlemi
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.3,
                          vertical: size.height * 0.02,
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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