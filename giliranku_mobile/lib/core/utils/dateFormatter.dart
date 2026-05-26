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

  static String toIndonesian(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String toShort(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String toTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  static String toRfc3339Utc(DateTime date) => date.toUtc().toIso8601String();
}