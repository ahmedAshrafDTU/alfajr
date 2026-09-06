import 'package:intl/intl.dart';

/// Helper utility for formatting Arabic times, dates, and durations.
class ArabicDateFormatter {
  static final DateFormat _timeFormat = DateFormat('hh:mm a', 'ar');
  static final DateFormat _dateFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');
  static final DateFormat _shortDateFormat = DateFormat('yyyy/MM/dd', 'ar');

  /// Formats a DateTime into 12-hour Arabic time (e.g., 04:23 ص).
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// Formats a DateTime into a full Arabic date string.
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formats short date (2026/09/03).
  static String formatShortDate(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  /// Formats duration countdown (e.g. "02:45:10" or "45 دقيقة").
  static String formatRemainingTime(Duration duration) {
    if (duration.isNegative) return 'حان الآن';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (minutes > 0) {
      return '$minutes دقيقة و $seconds ثانية';
    } else {
      return '$seconds ثانية';
    }
  }

  /// Converts English digits to Arabic-Indic digits if needed.
  static String toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
