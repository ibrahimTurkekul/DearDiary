class SettingsModel {
  bool skipMoodSelection;
  bool showMoodInCalendar;
  String? firstDayOfWeek;
  String? dateFormat;
  String? timeFormat;
  String? theme;

  // Bildirim ayarları için yeni alanlar
  bool dailyReminderEnabled;
  bool pinnedNotificationEnabled; // Sabit bildirim için
  String reminderTime; // "HH:mm" formatında saklanacak
  String reminderSentence;

  SettingsModel({
    required this.skipMoodSelection,
    required this.showMoodInCalendar,
    this.firstDayOfWeek,
    this.dateFormat,
    this.timeFormat,
    this.theme,
    // Yeni alanlar için varsayılan değerler
    this.dailyReminderEnabled = false,
    this.pinnedNotificationEnabled = false, // Varsayılan olarak kapalı
    this.reminderTime = "08:00", // Varsayılan olarak sabah 8
    this.reminderSentence = "Bugünkü notunuzu yazmayı unutmayın!",
  });

  // JSON'dan SettingsModel oluşturma
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      skipMoodSelection: json['skipMoodSelection'] ?? false,
      showMoodInCalendar: json['showMoodInCalendar'] ?? false,
      firstDayOfWeek: json['firstDayOfWeek'],
      dateFormat: json['dateFormat'],
      timeFormat: json['timeFormat'],
      theme: json['theme'],
      dailyReminderEnabled: json['dailyReminderEnabled'] ?? false,
      pinnedNotificationEnabled: json['pinnedNotificationEnabled'] ?? false,
      reminderTime: json['reminderTime'] ?? "08:00",
      reminderSentence: json['reminderSentence'] ?? "Bugünkü notunuzu yazmayı unutmayın!",
    );
  }

  // SettingsModel'i JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'skipMoodSelection': skipMoodSelection,
      'showMoodInCalendar': showMoodInCalendar,
      'firstDayOfWeek': firstDayOfWeek,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'theme': theme,
      'dailyReminderEnabled': dailyReminderEnabled,
      'pinnedNotificationEnabled': pinnedNotificationEnabled,
      'reminderTime': reminderTime,
      'reminderSentence': reminderSentence,
    };
  }
}