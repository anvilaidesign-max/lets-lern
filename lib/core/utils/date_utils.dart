/// Date helpers. Days are stored as local `yyyy-MM-dd` keys so streaks follow
/// the user's own calendar day.
class DateKeys {
  DateKeys._();

  static String dayKey(DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// Parses a `yyyy-MM-dd` key into a local midnight [DateTime].
  static DateTime parseDayKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  /// Calendar-safe day arithmetic (DST days are not always 24 hours long).
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days, date.hour, date.minute, date.second);

  static bool isWeekend(DateTime date) =>
      date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  /// Next Saturday 00:00 (today if it is already Saturday).
  static DateTime nextSaturday(DateTime from) {
    final start = startOfDay(from);
    final days = (DateTime.saturday - start.weekday) % 7;
    return addDays(start, days);
  }
}

/// A wall-clock time such as "21:30", used for quiet hours.
class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  static ClockTime? tryParse(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    if (h > 23 || m > 59) return null;
    return ClockTime(h, m);
  }

  int get minutesOfDay => hour * 60 + minute;

  DateTime onDay(DateTime day) => DateTime(day.year, day.month, day.day, hour, minute);

  @override
  int compareTo(ClockTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
