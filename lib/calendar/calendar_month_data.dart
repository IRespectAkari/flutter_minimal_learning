
class CalendarMonthData {
  /// 指定日を含む週の日曜日を返す。
  static DateTime sundayOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  /// 基準週の日曜日から、指定した週数だけ移動する。
  static DateTime weekStartAt(DateTime baseSunday, int weekOffset) {
    return baseSunday.add(Duration(days: weekOffset * 7));
  }

  /// 指定した日が月初かどうか。
  static bool isMonthStart(DateTime date) => date.day == 1;

  /// 指定した日の翌日が別の月になるかどうか。
  static bool isMonthEnd(DateTime date) {
    final nextDay = date.add(const Duration(days: 1));
    return date.month != nextDay.month ||
        date.year != nextDay.year;
  }
}
