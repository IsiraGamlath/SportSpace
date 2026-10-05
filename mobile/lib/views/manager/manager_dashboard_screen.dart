import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/metric_card.dart';
import '../../widgets/manager/schedule_tile.dart';
import 'manager_booking_details_screen.dart';
import 'manager_notifications_screen.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  final ValueChanged<int>? onNavigateTab;

  void _openBookingDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerBookingDetailsScreen(),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
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
                  _TopBar(onNotificationsTap: () => _openNotifications(context)),
                  const SizedBox(height: 18),

                  const Text(
                    'Good morning, Nimal',
                    style: TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 20,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Colombo Sports Centre',
                    style: TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          value: '18',
                          label: "Today's Bookings",
                          valueColor: ManagerColors.navy,
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          value: '4',
                          label: 'Pending Payments',
                          valueColor: ManagerColors.amber,
                          onTap: () => _openBookingDetails(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          value: '2',
                          label: 'Maintenance Issues',
                          valueColor: ManagerColors.red,
                          onTap: () => onNavigateTab?.call(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          value: '27',
                          label: 'Available Slots',
                          valueColor: ManagerColors.teal,
                          onTap: () => onNavigateTab?.call(1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: () => onNavigateTab?.call(3),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ManagerColors.amberBorder,
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 20,
                            color: ManagerColors.amber,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '2 facilities require attention.',
                            style: TextStyle(
                              color: ManagerColors.navy,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: ManagerColors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: TextStyle(
                          color: ManagerColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab?.call(1),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View Full Schedule',
                          style: TextStyle(
                            color: ManagerColors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ScheduleTile(
                    time: '5:00 PM',
                    title: 'Badminton Court 1',
                    subtitle: 'Player booking',
                    status: ScheduleStatus.confirmed,
                    onTap: () => _openBookingDetails(context),
                  ),
                  const SizedBox(height: 10),
                  ScheduleTile(
                    time: '5:30 PM',
                    title: 'Tennis Court 2',
                    subtitle: 'Player booking',
                    status: ScheduleStatus.paid,
                    onTap: () => _openBookingDetails(context),
                  ),
                  const SizedBox(height: 10),
                  ScheduleTile(
                    time: '6:00 PM',
                    title: 'Basketball Court',
                    subtitle: 'Player booking',
                    status: ScheduleStatus.pendingPayment,
                    onTap: () => _openBookingDetails(context),
                  ),
                  const SizedBox(height: 10),
                  ScheduleTile(
                    time: '6:30 PM',
                    title: 'Badminton Court 3',
                    subtitle: 'Player booking',
                    status: ScheduleStatus.confirmed,
                    onTap: () => _openBookingDetails(context),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _openBookingDetails(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ManagerColors.navy,
                        side: const BorderSide(
                          color: ManagerColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'View Bookings & Payment Verification',
                        style: TextStyle(
                          fontSize: 13.5,
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 20,
          color: ManagerColors.navy,
        ),
        const SizedBox(width: 6),
        const Text(
          'SportSpace',
          style: TextStyle(
            color: ManagerColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: ManagerColors.tealSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Manager',
            style: TextStyle(
              color: ManagerColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: ManagerColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: onNotificationsTap,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: ManagerColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFF245D7D),
          child: Text(
            'NF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
