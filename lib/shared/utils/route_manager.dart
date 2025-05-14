import 'package:deardiary/features/calendar/calendar_page.dart';
import 'package:deardiary/features/diary/pages/edit_page.dart';
import 'package:deardiary/features/diary/pages/home_page.dart';
import 'package:deardiary/features/diary/pages/search_page.dart';
import 'package:deardiary/features/settings/pages/backup_options_page.dart';
import 'package:deardiary/features/settings/pages/date_format_popup.dart';
import 'package:deardiary/features/settings/pages/diary_lock/diary_lock_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/email_setup_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/forgot_password_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/pattern_lock_setup_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/pattern_lock_verify_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/pin_lock_setup_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/pin_lock_verify_page.dart';
import 'package:deardiary/features/settings/pages/diary_lock/security_question_page.dart';
import 'package:deardiary/features/settings/pages/donation_page.dart';
import 'package:deardiary/features/settings/pages/feedback_page.dart';
import 'package:deardiary/features/settings/pages/first_day_of_week_popup.dart';
import 'package:deardiary/features/settings/pages/language_selection_page.dart';
import 'package:deardiary/features/settings/pages/mood_style_page.dart';
import 'package:deardiary/features/settings/pages/notification_page.dart';
import 'package:deardiary/features/settings/pages/privacy_policy_page.dart';
import 'package:deardiary/features/settings/pages/settings_page.dart';
import 'package:deardiary/features/settings/pages/theme_page.dart';
import 'package:deardiary/features/settings/pages/time_format_popup.dart';
import 'package:deardiary/shared/utils/navigation_service.dart';
import 'package:flutter/material.dart';
import '../../features/diary/pages/addEntryPages/add_entry_page.dart';
import '../../features/diary/pages/preview_page.dart';
import '../../features/diary/models/diary_entry.dart';

class RouteManager {
  static BuildContext? get context => NavigationService().navigatorKey.currentContext;
  static const String firstDayOfWeek = '/firstDayOfWeek';
  static const String dateFormat = '/dateFormat'; // Tarih formatı rotası
  static const String timeFormat = '/timeFormat'; // Zaman formatı rotası

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Ana sayfa rotası
        return MaterialPageRoute(builder: (_) => const DiaryHomePage());

      case '/addEntry':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final DateTime? date = args['date'];
        return MaterialPageRoute(builder: (_) => AddEntryPage(date: date));

      case '/edit':
        // Düzenleme sayfasına geçiş
        if (settings.arguments == null) {
          return _errorRoute('EditPage requires a DiaryEntry argument.');
        }
        final args = settings.arguments as Map<String, dynamic>;
        final DiaryEntry? entry = args['entry'];
        if (entry == null) {
          return _errorRoute('EditPage received a null DiaryEntry.');
        }
        return MaterialPageRoute(builder: (_) => EditPage(entry: entry));

      case '/preview':
        // Önizleme sayfasına geçiş
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        if (args['initialIndex'] == null) {
          return _errorRoute('PreviewPage requires an initialIndex argument.');
        }
        final int initialIndex = args['initialIndex'];
        return MaterialPageRoute(
          builder: (_) => PreviewPage(initialIndex: initialIndex),
        );

      case '/calendar':
        // Takvim sayfasına geçiş
        return MaterialPageRoute(builder: (_) => const CalendarPage());

      case '/search':
        // Arama sayfasına geçiş
        return MaterialPageRoute(builder: (_) => const SearchPage());

      case '/settings':
        // Ayarlar sayfasına geçiş
        return MaterialPageRoute(builder: (_) => const SettingsPage());

      case '/moodStyle':
        return MaterialPageRoute(builder: (_) => const MoodStylePage());
      case '/dailyLock':
        return MaterialPageRoute(builder: (_) => const Scaffold()); // Günlük Kilidi sayfası için placeholder
      case '/backupOptions':
        return MaterialPageRoute(builder: (_) => const BackupOptionsPage());
      case '/theme':
        return MaterialPageRoute(builder: (_) => const ThemePage());
      case '/widgetSettings':
        return MaterialPageRoute(builder: (_) => const Scaffold()); // Widget ayarları için placeholder
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case '/firstDayOfWeek':
        return MaterialPageRoute(builder: (_) => const FirstDayOfWeekPopup());
      case '/dateFormat':
        return MaterialPageRoute(builder: (_) => const DateFormatPopup());
      case '/timeFormat':
        return MaterialPageRoute(builder: (_) => const TimeFormatPopup());
      case '/privacyPolicy':
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      case '/feedback':
        return MaterialPageRoute(builder: (_) => const FeedbackPage());
      case '/languageSelection':
        return MaterialPageRoute(builder: (_) => const LanguageSelectionPage());
      case '/donation':
        return MaterialPageRoute(builder: (_) => const DonationPage());
      case '/patternLockSetup':
        // Pattern Lock Setup sayfasına argüman geçişi
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => PatternLockSetupPage(lockType: args['lockType']), // lockType argümanı ile geçiş
        );
      case '/patternLockVerify':
        return MaterialPageRoute(builder: (_) => const PatternLockVerifyPage());
      case '/pinLockVerify':
        return MaterialPageRoute(builder: (_) => PinLockVerifyPage());
      
      case '/securityQuestionSetup':
        // Güvenlik sorusu sayfasına geçiş
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        if (!args.containsKey('lockType')) {
          return _errorRoute("SecurityQuestionSetupPage requires a 'lockType' argument.");
        }
        return MaterialPageRoute(
          builder: (_) => SecurityQuestionPage(
            lockType: args['lockType'], // Kilit türü argümanı
            pattern: args['pattern'], // Desen kilidi için argüman
            pin: args['pin'], // PIN kilidi için argüman
          ),
        );
      case '/pinLockSetup':
        return MaterialPageRoute(
          builder: (_) => PinLockSetupPage(
            lockType: settings.arguments as String?, // lockType argümanı ile geçiş
          ),
        );
      case '/diaryLock':
        return MaterialPageRoute(builder: (_) => const DiaryLockPage()); // Günlük kilidi sayfası için placeholder
      case '/emailSetup':
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('selectedQuestion') || !args.containsKey('securityAnswer') || !args.containsKey('pattern') || !args.containsKey('pin')|| !args.containsKey('lockType')) {
          return _errorRoute('Eksik argüman: selectedQuestion, securityAnswer, pattern, pin veya lockType');
        }
        return MaterialPageRoute(
          builder: (_) => EmailSetupPage(
            selectedQuestion: args['selectedQuestion'],
            securityAnswer: args['securityAnswer'],
            pattern: args['pattern'],
            lockType: args['lockType'],
            pin: args['pin'], // PIN kilidi için argüman
          ),
        );
      case '/forgotPassword':
        return MaterialPageRoute(builder: (context) => const ForgotPasswordPage(),);
      default:
        // Varsayılan olarak 404 sayfası
        return _errorRoute('404 - Sayfa Bulunamadı');
    }
  }

  /// Hata için varsayılan bir route döner
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}