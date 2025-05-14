import 'package:flutter/material.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'package:provider/provider.dart';

class EmailSetupPage extends StatefulWidget {
  final String selectedQuestion; // Güvenlik sorusu
  final String securityAnswer; // Güvenlik sorusunun cevabı
  final List<int>? pattern; // Desen bilgisi (null olabilir)
  final String? pin; // PIN bilgisi (null olabilir)
  final String lockType; // Kilit türü (PIN, desen vb.)

  const EmailSetupPage({
    super.key,
    required this.selectedQuestion,
    required this.securityAnswer,
    required this.lockType,
    this.pattern, 
    this.pin,
    
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
            onPressed: () async {
              Navigator.pop(context); // Popup'ı kapat

              // Güvenlik sorusu ve desen bilgilerini kaydet
              final lockManager = LockManager();
              if (widget.pattern != null) {
                await lockManager.savePattern(widget.pattern!);
              }
              if (widget.pin != null) {
                await lockManager.savePin(widget.pin!);
              }
              await lockManager.setActiveLockType(widget.lockType);
              
              await lockManager.saveSecurityQuestion(
                widget.selectedQuestion,
                widget.securityAnswer,
              );
              await lockManager.activateDiaryLock(); // Günlük kilidini aktif hale getir

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bilgiler başarıyla kaydedildi. E-posta atlandı.")),
              );

              // Günlük kilidi sayfasına git, yığın temizlenir
              navigationService.navigateToAndClearStack('/diaryLock');
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

    await lockManager.clearAll();

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
      if (widget.pattern != null) {
         await lockManager.savePattern(widget.pattern!);
      }
      if (widget.pin != null) {
         await lockManager.savePin(widget.pin!);
      }

      await lockManager.setActiveLockType(widget.lockType);

      await lockManager.saveSecurityQuestion(
        widget.selectedQuestion,
        widget.securityAnswer,
      );
      await lockManager.saveEmail(emailController.text);
      await lockManager.activateDiaryLock(); // Günlük kilidini aktif hale getir

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bilgiler başarıyla kaydedildi")),
      );

      // Günlük kilidi sayfasına dön, yığın temizlenir
      Future.delayed(const Duration(seconds: 1), () {
        navigationService.navigateToAndClearStack('/diaryLock');
      });
    }
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
      navigationService.navigateToAndClearStack('/diaryLock');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutlarını alır

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("E-posta Adresini Ayarla"),
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
            color: Colors.black.withOpacity(0.90), // Siyaha yakın ton
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