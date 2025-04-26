class MoodService {
  String _moodStyle = "Default";

  String get moodStyle => _moodStyle;

  void setMoodStyle(String style) {
    _moodStyle = style;
    // Burada ruh hali tarzına bağlı ek işlemler yapılabilir
  }
}