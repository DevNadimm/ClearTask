import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormatter = DateFormat('MMMM d, yyyy');
  static final _dateTimeFormatter = DateFormat('MMMM d, yyyy - h:mm a');

  /// Converts a raw ISO date string (e.g. "2025-06-10T00:00:00.000")
  /// to a formatted string like "June 10, 2025"
  static String toLongMonthDayYear(String rawDateStr) {
    final date = DateTime.parse(rawDateStr);
    return _dateFormatter.format(date);
  }

  /// Converts a formatted date string like "June 10, 2025"
  /// back to a raw ISO string like "2025-06-10T00:00:00.000"
  static String toRawDateTime(String formattedDateStr) {
    final parsedDate = _dateFormatter.parse(formattedDateStr);
    return parsedDate.toIso8601String();
  }

  /// Converts a raw ISO datetime string to formatted string like "June 10, 2025 - 4:30 PM"
  static String toLongMonthDayYearTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return _dateTimeFormatter.format(dateTime);
  }

  /// Parses a formatted datetime string like "June 10, 2025 - 4:30 PM"
  /// back to DateTime object
  static String fromLongMonthDayYearTime(String formattedDateTime) {
    return _dateTimeFormatter.parse(formattedDateTime).toString();
  }

  /// Parses a raw ISO date string to DateTime object
  static DateTime parseDateTime(String date) {
    return DateTime.parse(date);
  }
}
