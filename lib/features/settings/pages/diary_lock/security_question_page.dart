import 'package:flutter/material.dart';

class SecurityQuestionPage extends StatefulWidget {
  const SecurityQuestionPage({super.key});

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

  @override
  void initState() {
    super.initState();
    // Sayfa yüklendiğinde textfield otomatik olarak focuslanır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_answerFocusNode);
    });
  }

  final FocusNode _answerFocusNode = FocusNode();

  void _showExitPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Şifre Kurulumu İptal Edilsin mi?"),
        content: const Text(
          "Kurulum işlemini şimdi iptal ederseniz şifreniz kaydedilmeyecektir.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Popup'ı kapat
              Navigator.pop(context); // Günlük kilidi sayfasına git
            },
            child: const Text("İptal"),
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

  void _onConfirm() {
    // E-posta adresi kayıt sayfasına geçiş
    Navigator.pushNamed(context, '/emailSetupPage');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutlarını alır

    return Scaffold(
      appBar: AppBar(
        title: const Text("Güvenlik Sorusunu Ayarla"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showExitPopup(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1, // Responsive yatay padding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.03), // Üst boşluk
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
    );
  }
}