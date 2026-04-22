/// Shared date/time formatting helpers used across the app.
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Returns e.g. "21 April 2026"
  static String toIndonesian(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// Returns e.g. "21-04-2026"
  static String toShort(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Returns e.g. "09:30"
  static String toTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// Converts to RFC3339/ISO-8601 UTC string for backend consumption.
  static String toRfc3339Utc(DateTime date) => date.toUtc().toIso8601String();
}
