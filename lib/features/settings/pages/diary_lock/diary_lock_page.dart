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
  String? registeredEmail;

  @override
  void initState() {
    super.initState();
    _checkExistingLock(); // Cihazda kayıtlı bir şifre var mı kontrol et
    _loadRegisteredEmail(); // Kayıtlı e-posta adresini yükle
  }

  Future<void> _checkExistingLock() async {
    final lockManager = LockManager();

    // Gerçek kullanıcı şifrelerini kontrol et
    final lockEnabled = await lockManager.isDiaryLockEnabled();
    final hasPattern = await lockManager.isPatternSet(); // Kayıtlı bir desen var mı kontrol edilir
    final hasPin = await lockManager.isPinSet(); // Kayıtlı bir PIN var mı kontrol edilir

    setState(() {
      isDiaryLockEnabled = lockEnabled;
      hasExistingLock = hasPattern || hasPin;
    });
  }

  Future<void> _loadRegisteredEmail() async {
    final lockManager = LockManager();
    final email = await lockManager.getEmail(); // E-posta adresini al
    setState(() {
      registeredEmail = email; // E-postayı state'e ata
    });
  }


  Future<void> _onDiaryLockToggleChanged(bool value) async {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final lockManager = LockManager();

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

    await lockManager.setDiaryLockEnabled(value);
    setState(() {
      isDiaryLockEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          navigationService.navigateTo('/'); // Ayarlar sayfasına geri dön
        },
      ),
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
                SecurityQuestionDialog.show(context); // Güvenlik sorusu sayfasına git
              },
            ),
            // E-posta adresi ayarla
            ListTile(
              title: const Text("E-posta Adresini Ayarla"),
              subtitle: registeredEmail != null
                  ? Text("Kayıtlı e-posta: $registeredEmail")
                  : const Text("Geri alma işlemleri için e-posta adresinizi ayarlayın."),
              onTap: () {
                EmailUpdateDialog.show(
                  context,
                  (updatedEmail) {
                    setState(() {
                      registeredEmail = updatedEmail; // Güncel e-posta adresini state'e ata
                    });
                  },
                );
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
class SecurityQuestionDialog {
  static final List<String> defaultSecurityQuestions = [
    "Evcil hayvanınızın adı nedir?",
    "İlkokul öğretmeninizin adı nedir?",
    "En sevdiğiniz film nedir?",
    "Doğduğunuz şehir nedir?",
    "Kendi sorumu yazmak istiyorum"
  ];

  /// Güvenlik sorusu güncelleme için bir diyalog göster
  static Future<void> show(BuildContext context) async {
    final TextEditingController customQuestionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    String? selectedQuestion = defaultSecurityQuestions.first;

    final lockManager = LockManager();
    final currentQuestion = await lockManager.getSecurityQuestion();
    if (currentQuestion != null && !defaultSecurityQuestions.contains(currentQuestion)) {
      selectedQuestion = "Kendi sorumu yazmak istiyorum";
      customQuestionController.text = currentQuestion;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Güvenlik Sorusu Güncelle"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedQuestion,
                    isExpanded: true,
                    items: defaultSecurityQuestions.map((String question) {
                      return DropdownMenuItem<String>(
                        value: question,
                        child: Text(question),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedQuestion = value;
                        if (value != "Kendi sorumu yazmak istiyorum") {
                          customQuestionController.clear();
                        }
                      });
                    },
                  ),
                  if (selectedQuestion == "Kendi sorumu yazmak istiyorum")
                    TextField(
                      controller: customQuestionController,
                      decoration: const InputDecoration(
                        labelText: "Kendi Sorunuz",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: answerController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Cevap",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Diyaloğu kapat
                  },
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final question = selectedQuestion == "Kendi sorumu yazmak istiyorum"
                        ? customQuestionController.text.trim()
                        : selectedQuestion;
                    final answer = answerController.text.trim();

                    if (question == null || question.isEmpty || answer.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
                      );
                      return;
                    }

                    // Güvenlik sorusunu kaydet
                    await lockManager.saveSecurityQuestion(question, answer);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Güvenlik sorusu başarıyla güncellendi.")),
                    );
                    Navigator.of(context).pop(); // Diyaloğu kapat
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class EmailUpdateDialog {
  /// E-posta adresi güncelleme için bir diyalog göster
  static Future<void> show(BuildContext context, Function(String) onEmailUpdated) async {
    final TextEditingController emailController = TextEditingController();

    // Mevcut e-posta adresini yükle
    final lockManager = LockManager();
    final currentEmail = await lockManager.getEmail();
    emailController.text = currentEmail ?? "";

    // E-posta doğrulama regex'i
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("E-posta Güncelle"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "E-posta Adresi",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                // Boş e-posta kontrolü
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lütfen bir e-posta adresi girin.")),
                  );
                  return;
                }

                // Geçersiz e-posta formatı kontrolü
                if (!emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Geçerli bir e-posta adresi girin.")),
                  );
                  return;
                }

                try {
                  // E-posta adresini kaydet
                  await lockManager.saveEmail(email);

                  // Ekranı güncellemek için callback çağrılıyor
                  onEmailUpdated(email);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("E-posta başarıyla güncellendi.")),
                  );

                  Navigator.of(context).pop(); // Diyaloğu kapat
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hata: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }
}