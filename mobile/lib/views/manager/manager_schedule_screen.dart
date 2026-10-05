import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/schedule_card.dart';
import 'manager_booking_details_screen.dart';
import 'manager_notifications_screen.dart';

class ManagerScheduleScreen extends StatefulWidget {
  const ManagerScheduleScreen({super.key});

  @override
  State<ManagerScheduleScreen> createState() => _ManagerScheduleScreenState();
}

class _ManagerScheduleScreenState extends State<ManagerScheduleScreen> {
  bool _daySelected = true;
  int _selectedCourt = 0;

  final List<String> _courts = [
    'All Courts',
    'Badminton',
    'Tennis',
    'Basketball',
  ];

  void _openBookingDetails() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerBookingDetailsScreen(),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  void _showAddSlotModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            MediaQuery.of(context).viewInsets.bottom + 26,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Block Slot or Add Schedule',
                    style: TextStyle(
                      color: ManagerColors.navyDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Court: Badminton Court 1',
                style: TextStyle(
                  color: ManagerColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Time: 7:30 PM - 8:30 PM',
                style: TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Slot marked as Available')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text('Add Slot', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Slot blocked successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: ManagerColors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text('Block Slot', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDayWeekSwitch(),
                  const SizedBox(height: 18),
                  _buildDateRow(),
                  const SizedBox(height: 14),
                  _buildCourtFilters(),
                  const SizedBox(height: 18),

                  ScheduleCard(
                    time: '5:00 PM',
                    title: 'Badminton Court 1',
                    status: ScheduleCardStatus.booked,
                    onTap: _openBookingDetails,
                  ),
                  const SizedBox(height: 10),

                  ScheduleCard(
                    time: '5:30 PM',
                    title: 'Tennis Court 1',
                    status: ScheduleCardStatus.available,
                    onTap: _openBookingDetails,
                  ),
                  const SizedBox(height: 10),

                  ScheduleCard(
                    time: '6:00 PM',
                    title: 'Badminton Court 2',
                    status: ScheduleCardStatus.pending,
                    onTap: _openBookingDetails,
                  ),
                  const SizedBox(height: 10),

                  ScheduleCard(
                    time: '6:30 PM',
                    title: 'Basketball Court',
                    status: ScheduleCardStatus.booked,
                    onTap: _openBookingDetails,
                  ),
                  const SizedBox(height: 10),

                  _BlockedScheduleCard(onTap: _showAddSlotModal),
                  const SizedBox(height: 10),

                  ScheduleCard(
                    time: '7:00 PM',
                    title: 'Badminton Court 1',
                    status: ScheduleCardStatus.available,
                    onTap: _openBookingDetails,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _showAddSlotModal,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ManagerColors.navy,
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: ManagerColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        '+ Add Schedule / Block Slot',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Real-time Schedule',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: _openNotifications,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: ManagerColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayWeekSwitch() {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Day',
              selected: _daySelected,
              onTap: () => setState(() => _daySelected = true),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegmentButton(
              label: 'Week',
              selected: !_daySelected,
              onTap: () => setState(() => _daySelected = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Wednesday, 16 September',
            style: TextStyle(
              color: ManagerColors.navyDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Date picker opened')),
              );
            },
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.calendar_month_outlined,
              size: 19,
              color: ManagerColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _courts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedCourt;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _selectedCourt = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? ManagerColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? ManagerColors.navy : ManagerColors.chipBorder,
                ),
              ),
              child: Text(
                _courts[index],
                style: TextStyle(
                  color: selected ? Colors.white : ManagerColors.navyDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ManagerColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : ManagerColors.navyDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BlockedScheduleCard extends StatelessWidget {
  const _BlockedScheduleCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCED8E1),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '6:45 PM',
                    style: TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tennis Court 1 — Under Maintenance',
                    style: TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ManagerColors.blockedSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Blocked',
                style: TextStyle(
                  color: ManagerColors.blockedText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
