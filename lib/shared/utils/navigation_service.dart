import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  

  /// Normal sayfa yönlendirme
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  /// Yönlendirme yaparken önceki yığınları temizle
  Future<dynamic> navigateToAndClearStack(String routeName, {Object? arguments}) {

    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false, // Tüm önceki sayfaları kaldır
      arguments: arguments,
    );
  }

  /// Yönlendirme yaparken önceki yığınları belirli bir koşula göre temizle
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {required String untilRoute, Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(untilRoute),
      arguments: arguments,
    );
  }

  /// Mevcut sayfayı başka bir sayfa ile değiştir
  Future<dynamic> replaceWith(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Mevcut sayfanın kontrolü
  bool isOnScreen(String routeName) {
    final currentContext = navigatorKey.currentContext;
    if (currentContext != null) {
      final route = ModalRoute.of(currentContext);
      return route?.settings.name == routeName;
    }
    return false;
  }

  /// Geri dön
  void goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }

  /// Tarih seçerek giriş ekranına git
  Future<dynamic> navigateToAddEntry({DateTime? date}) {
    final now = DateTime.now();
    final selectedDate = DateTime(
      date?.year ?? now.year,
      date?.month ?? now.month,
      date?.day ?? now.day,
      now.hour,
      now.minute,
    );
    return navigateTo('/addEntry', arguments: {'date': selectedDate});
  }

  /// Diğer yönlendirme metotları
  Future<dynamic> navigateToPreview(int index) => navigateTo('/preview', arguments: {'initialIndex': index});
  Future<dynamic> navigateToCalendar() => navigateTo('/calendar');
  Future<dynamic> navigateToSearch() => navigateTo('/search');

  /// Ayarlarla ilgili yönlendirmeler
  Future<dynamic> navigateToSettings() => navigateTo('/settings');
  Future<dynamic> navigateToTheme() => navigateTo('/theme');
  Future<dynamic> navigateToTimeFormat() => navigateTo('/timeFormat');
  Future<dynamic> navigateToFirstDayOfWeek() => navigateTo('/firstDayOfWeek');
  Future<dynamic> navigateToDateFormat() => navigateTo('/dateFormat');
  Future<dynamic> navigateToMoodStyle() => navigateTo('/moodStyle');
  Future<dynamic> navigateToBackupOptions() => navigateTo('/backupOptions');
  Future<dynamic> navigateToNotifications() => navigateTo('/notifications');
  Future<dynamic> navigateToForgotPassword() => navigateTo('/forgotPassword');

  /// Günlük kilidiyle ilgili yönlendirmeler
  Future<dynamic> navigateToDiaryLockPage() => navigateTo('/diaryLock');
  Future<dynamic> navigateToPatternLockSetupPage() => navigateTo('/patternLockSetup');
  Future<dynamic> navigateToSecurityQuestionSetupPage() => navigateTo('/securityQuestionSetup');
  Future<dynamic> navigateToPinLockSetupPage() => navigateTo('/pinLockSetup');
  Future<dynamic> navigateToDonationPage() => navigateTo('/emailSetup');
  Future<dynamic> navigateToEmailSetupPage() => navigateTo('/patternLockVerify');
  Future<dynamic> navigateToPinLockVerifyPage() => navigateTo('/pinLockVerify');
}