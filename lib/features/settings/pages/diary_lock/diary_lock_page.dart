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

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Günlük Kilidi Ayarları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Günlük Kilidi"),
              subtitle: const Text("Günlüğünüzü korumak için bir kilit ayarlayın."),
              value: isDiaryLockEnabled,
              onChanged: (value) {
                setState(() {
                  isDiaryLockEnabled = value;
                });
                if (value) {
                  navigationService.navigateTo('/patternLockSetup');
                }
              },
            ),
            ListTile(
              title: const Text("Şifreyi Belirle"),
              subtitle: const Text("Şifrenizi ayarlayın veya değiştirin."),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/patternLockSetup');
              },
            ),
            ListTile(
              title: const Text("Güvenlik Sorusunu Ayarla"),
              subtitle: const Text("Şifrenizi geri almak için kullanılacaktır."),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/securityQuestionSetup');
              },
            ),
            ListTile(
              title: const Text("E-posta Adresini Ayarla"),
              enabled: isDiaryLockEnabled,
              onTap: () {
                navigationService.navigateTo('/securityQuestionSetup');
              },
            ),
            SwitchListTile(
              title: const Text("Parmak İzini Etkinleştir"),
              value: false,
              onChanged: (value) {
                setState(() {
                  // Parmak izi etkinleştirildiğinde yapılacak işlemler
                });
              }, 
              
            ),
          ],
        ),
      ),
    );
  }
}