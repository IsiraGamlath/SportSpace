// lib/widgets/tertiary/date_selector.dart
//
// Reusable horizontal date selector (weekday abbreviation + day number
// pills) for the Events & Schedules screen's date filter row. Weekday
// labels are computed from the real DateTime passed in, not hardcoded.

import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  static const Color _selectedBg = Color(0xFF0D2B4E);
  static const Color _selectedText = Colors.white;
  static const Color _unselectedBg = Colors.white;
  static const Color _unselectedBorder = Color(0xFFE7EAF0);
  static const Color _unselectedWeekday = Color(0xFF8A93A3);
  static const Color _unselectedDay = Color(0xFF16202C);

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, selectedDate);
          final weekday = _weekdayLabels[date.weekday - 1];

          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: isSelected ? _selectedBg : _unselectedBg,
                borderRadius: BorderRadius.circular(14),
                border:
                    isSelected ? null : Border.all(color: _unselectedBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : _unselectedWeekday,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _selectedText : _unselectedDay,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}