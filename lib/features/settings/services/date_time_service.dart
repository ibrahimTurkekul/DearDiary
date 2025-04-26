class DateTimeService {
  String _firstDayOfWeek = "Monday";
  String _dateFormat = "dd-MM-yyyy";
  String _timeFormat = "24-hour";

  String get firstDayOfWeek => _firstDayOfWeek;
  String get dateFormat => _dateFormat;
  String get timeFormat => _timeFormat;

  void setFirstDayOfWeek(String day) {
    _firstDayOfWeek = day;
  }

  void setDateFormat(String format) {
    _dateFormat = format;
  }

  void setTimeFormat(String format) {
    _timeFormat = format;
  }
}