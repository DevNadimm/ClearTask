import 'package:intl/intl.dart';

class DateFormatter {
  /// Converts a raw ISO date string like "2025-06-10T00:00:00.000"
  /// to a formatted string like "June 10, 2025"
  static String toLongMonthDayYear(String rawDateStr) {
    final formatter = DateFormat('MMMM d, yyyy');
    final date = DateTime.parse(rawDateStr);
    return formatter.format(date);
  }

  /// Converts a formatted date string like "June 10, 2025"
  /// back to a raw string like "2025-06-10 00:00:00.000"
  static String toRawDateTime(String formattedDateStr) {
    final formatter = DateFormat('MMMM d, yyyy');
    final parsedDate = formatter.parse(formattedDateStr);
    return parsedDate.toString();
  }

  static DateTime parseDateTime(String date) {
    return DateTime.parse(date);
  }
}
