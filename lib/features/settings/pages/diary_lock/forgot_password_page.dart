import 'package:flutter/material.dart';
import 'package:deardiary/features/settings/services/lock_manager.dart';
import 'email_verification_page.dart';
import 'security_question_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? email; // Kullanıcının kayıtlı e-posta adresi
  String? securityQuestion; // Kullanıcının kaydettiği güvenlik sorusu
  bool isLoading = true; // Ekranın yüklenme durumu

  @override
  void initState() {
    super.initState();
    _loadData(); // Verileri yükle
  }

  Future<void> _loadData() async {
    final lockManager = LockManager();

    // LockManager üzerinden verileri al
    final fetchedEmail = await lockManager.getEmail(); // E-posta adresini al
    final fetchedSecurityQuestion =
        await lockManager.getSecurityQuestion(); // Güvenlik sorusunu al

    setState(() {
      email = fetchedEmail;
      securityQuestion = fetchedSecurityQuestion;
      isLoading = false; // Yükleme tamamlandı
    });

    // Eğer e-posta kaydedilmemişse doğrudan güvenlik sorusu ekranına yönlendir
    if (email == null || email!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SecurityQuestionVerificationPage(
            question: securityQuestion,
          ),
        ),
      );
    }
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
        title: const Text("Şifremi Unuttum"),
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Şifrenizi almak için aşağıdaki yolları kullanabilirsiniz:",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildOptionTile(
                  context,
                  "Doğrulama E-postasını Kullan",
                  Icons.keyboard_arrow_right,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EmailVerificationPage(email: email),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionTile(
                  context,
                  "Güvenlik Sorusunu Kullan",
                  Icons.keyboard_arrow_right,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecurityQuestionVerificationPage(
                          question: securityQuestion,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return ListTile(
      tileColor: Colors.transparent, // Arka plan kaldırıldı
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      trailing: Icon(trailingIcon, color: Colors.white),
      onTap: onTap,
    );
  }
}