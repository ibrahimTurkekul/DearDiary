import 'package:flutter/material.dart';

class EmailVerificationPage extends StatelessWidget {
  final String? email;

  const EmailVerificationPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final obfuscatedEmail = email != null
        ? '${email!.substring(0, 2)}***${email!.substring(email!.length - 2)}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doğrulama E-postası"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "GÖNDER'e tıklayın, ardından şifrenizi içeren bir e-posta şu adrese gönderilecektir:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              obfuscatedEmail ?? "E-posta bulunamadı.",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Lütfen spam kutunuzu da kontrol ediniz.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // E-posta gönderme işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("E-posta gönderildi!")),
                );
              },
              child: const Text("GÖNDER"),
            ),
          ],
        ),
      ),
    );
  }
}