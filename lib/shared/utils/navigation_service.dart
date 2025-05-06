import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAddEntry({DateTime? date}) {
    // Eğer tarih verilmemişse, bugünün tarihini kullan
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

  Future<dynamic> navigateToPreview(int index) => navigateTo('/preview', arguments: {'initialIndex': index});

  Future<dynamic> navigateToCalendar() => navigateTo('/calendar'); // CalendarPage için eklenen kod

  Future<dynamic> navigateToSearch() => navigateTo('/search'); // SearchPage için eklenen kod

  Future<dynamic> navigateToSettings() => navigateTo('/settings'); // SettingsPage için eklenen kod

  Future<dynamic> navigateToTheme() => navigateTo('/theme'); // ThemePage için eklenen kod
  Future<dynamic> navigateToTimeFormat() => navigateTo('/timeFormat'); // TimeFormatPage için eklenen kod 
  Future<dynamic> navigateToFirstDayOfWeek() => navigateTo('/firstDayOfWeek'); // FirstDayOfWeekPage için eklenen kod
  Future<dynamic> navigateToDateFormat() => navigateTo('/dateFormat'); // DateFormatPage için eklenen kod 
  Future<dynamic> navigateToMoodStyle() => navigateTo('/moodStyle'); // MoodStylePage için eklenen kod
  Future<dynamic> navigateToBackupOptions() => navigateTo('/backupOptions'); // BackupOptionsPage için eklenen kod
  //Future<dynamic> navigateToWidgetSettings() => navigateTo('/widgetSettings'); // WidgetSettingsPage için eklenen kod 
  Future<dynamic> navigateToNotifications() => navigateTo('/notifications'); // NotificationPage için eklenen kod
  //Future<dynamic> navigateToPrivacyPolicy() => navigateTo('/privacyPolicy'); // PrivacyPolicyPage için eklenen kod  
  //Future<dynamic> navigateToLanguageSelection() => navigateTo('/languageSelection'); // LanguageSelectionPage için eklenen kod
  //Future<dynamic> navigateToFeedback() => navigateTo('/feedback'); // FeedbackPage için eklenen kod
  //Future<dynamic> navigateToDiaryLock() => navigateTo('/donations'); 
  Future<dynamic> navigateToDiaryLockPage() => navigateTo('/diaryLock');
  Future<dynamic> navigateToPatternLockSetupPage() => navigateTo('/patternLockSetup');
  Future<dynamic> navigateToSecurityQuestionSetupPage() => navigateTo('/securityQuestionSetup');
  Future<dynamic> navigateToPinLockSetupPage() => navigateTo('/pinLockSetup');
  Future<dynamic> navigateToDonationPage() => navigateTo('/emailSetup'); 
  Future<dynamic> navigateToEmailSetupPage() => navigateTo('/patternLockVerify');
 

  

  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}