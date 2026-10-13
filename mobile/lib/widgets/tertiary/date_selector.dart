// lib/widgets/tertiary/date_selector.dart
//
// Horizontal date selector displaying month & year header, weekday abbreviation,
// day number, and an embedded indicator dot for today's date. Supports swiping
// horizontally so users can browse and select future dates.

import 'package:flutter/material.dart';

class DateSelector extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late final ScrollController _scrollController;

  static const Color _selectedBg = Color(0xFF0D2B4E);
  static const Color _selectedText = Colors.white;
  static const Color _unselectedBg = Colors.white;
  static const Color _unselectedBorder = Color(0xFFE7EAF0);
  static const Color _unselectedWeekday = Color(0xFF8A93A3);
  static const Color _unselectedDay = Color(0xFF16202C);
  static const Color _heading = Color(0xFF0F2A44);

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(covariant DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    final index =
        widget.dates.indexWhere((d) => _isSameDay(d, widget.selectedDate));
    if (index > 0) {
      final target =
          (index * 66.0).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String _formatMonthYear(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final monthYearTitle = _formatMonthYear(widget.selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            monthYearTitle,
            key: const Key('date_selector_month_year'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _heading,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.separated(
            key: const Key('date_selector_list_view'),
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.dates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = widget.dates[index];
              final isSelected = _isSameDay(date, widget.selectedDate);
              final isToday = _isToday(date);
              final weekday = _weekdayLabels[date.weekday - 1];

              return InkWell(
                key: Key('date_selector_pill_${date.year}_${date.month}_${date.day}'),
                onTap: () => widget.onDateSelected(date),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? _selectedBg : _unselectedBg,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? null
                        : Border.all(color: _unselectedBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected ? Colors.white70 : _unselectedWeekday,
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
                      const SizedBox(height: 3),
                      if (isToday)
                        Container(
                          key: const Key('date_selector_today_dot'),
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0D2B4E),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 4.5),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}