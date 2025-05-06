import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SecurityQuestionPage extends StatefulWidget {
  final List<int> pattern; // Desen bilgisi

  const SecurityQuestionPage({super.key, required this.pattern});

  @override
  State<SecurityQuestionPage> createState() => _SecurityQuestionPageState();
}

class _SecurityQuestionPageState extends State<SecurityQuestionPage> {
  final List<String> questions = [
    "İlk evcil hayvanınızın adı nedir?",
    "Doğduğunuz şehir nedir?",
    "En sevdiğiniz öğretmeninizin adı nedir?",
    "İlk okulunuzun adı nedir?",
    "En sevdiğiniz yemek nedir?",
  ];

  String selectedQuestion = "İlk evcil hayvanınızın adı nedir?";
  final TextEditingController answerController = TextEditingController();

  final FocusNode _answerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde textfield otomatik olarak focuslanır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_answerFocusNode);
    });
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
      // Günlük kilidi toggle'ını pasif hale getir ve geri dön
      navigationService.navigateTo('/diaryLock');
    }
  }

  void _onConfirm() {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    // Kullanıcı cevabı girmemişse hata ver
    if (answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen güvenlik sorusunun cevabını yazınız.")),
      );
      return;
    }

    // Kullanıcıyı e-posta sayfasına yönlendir
    navigationService.navigateTo(
      '/emailSetup',
      arguments: {
        'selectedQuestion': selectedQuestion,
        'securityAnswer': answerController.text,
        'pattern': widget.pattern,
      },);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutlarını alır

    return WillPopScope(
      onWillPop: () async {
        await _handleExit();
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Güvenlik Sorusunu Ayarla"),
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
                      "Lütfen şifrenizi unutmanız durumunda kullanılacak olan bir güvenlik sorusu belirleyin.",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.05), // Boşluk
                    // Soru seçimi
                    DropdownButtonFormField<String>(
                      value: selectedQuestion,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: questions
                          .map((question) => DropdownMenuItem(
                                value: question,
                                child: Text(question),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedQuestion = value!;
                        });
                      },
                    ),
                    SizedBox(height: size.height * 0.03), // Boşluk
                    // Cevap alanı
                    TextField(
                      focusNode: _answerFocusNode,
                      controller: answerController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Lütfen cevabınızı yazınız",
                      ),
                    ),
                    SizedBox(height: size.height * 0.1), // Alt boşluk
                    // Onayla butonu
                    Center(
                      child: ElevatedButton(
                        onPressed: _onConfirm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.3,
                            vertical: size.height * 0.02,
                          ),
                        ),
                        child: const Text(
                          "Onayla",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
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