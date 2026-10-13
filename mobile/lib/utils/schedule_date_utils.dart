// lib/utils/schedule_date_utils.dart
//
// Utility for generating real-world calendar day strings synchronized
// across player slot booking, facility manager schedule & slot creation,
// and community member events.

class ScheduleDateUtils {
  static const List<String> weekdayShorts = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Generates real-world day labels starting from today:
  /// ['Today', 'Tomorrow', 'Wed 14', 'Thu 15', 'Fri 16', ...]
  static List<String> generateRealWorldDays({int count = 7, DateTime? startDate}) {
    final now = startDate ?? DateTime.now();
    return List.generate(count, (i) {
      if (i == 0) return 'Today';
      if (i == 1) return 'Tomorrow';
      final date = now.add(Duration(days: i));
      final weekday = weekdayShorts[date.weekday - 1];
      return '$weekday ${date.day}';
    });
  }

  /// Resolves the DateTime object for a given day label relative to today.
  static DateTime resolveDate(String label, {DateTime? startDate}) {
    final now = startDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (label == 'Today') return today;
    if (label == 'Tomorrow') return today.add(const Duration(days: 1));

    final days = generateRealWorldDays(count: 30, startDate: startDate);
    final idx = days.indexOf(label);
    if (idx != -1) {
      return today.add(Duration(days: idx));
    }
    return today;
  }
}
