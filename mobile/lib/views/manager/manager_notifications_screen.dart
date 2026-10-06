import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/notification_card.dart';

class ManagerNotificationsScreen extends StatefulWidget {
  const ManagerNotificationsScreen({super.key});

  @override
  State<ManagerNotificationsScreen> createState() =>
      _ManagerNotificationsScreenState();
}

class _ManagerNotificationsScreenState
    extends State<ManagerNotificationsScreen> {
  int _selectedFilter = 0;

  final List<String> _filters = [
    'All',
    'Events',
    'Schedules',
    'Facilities',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManagerColors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width =
                constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: ManagerColors.border),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                size: 22,
                                color: ManagerColors.navy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: ManagerColors.navyDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final selected = index == _selectedFilter;

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                setState(() {
                                  _selectedFilter = index;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ManagerColors.navy
                                      : ManagerColors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected
                                        ? ManagerColors.navy
                                        : ManagerColors.border,
                                  ),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: TextStyle(
                                    color: selected
                                        ? ManagerColors.white
                                        : ManagerColors.navyDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      const NotificationCard(
                        type: NotificationType.schedule,
                        title: 'Schedule Updated',
                        showUnreadDot: true,
                        message:
                            'Colombo Community Badminton Open — start time changed from 9:00 AM to 10:00 AM.',
                        timeAgo: '10 minutes ago',
                      ),

                      const SizedBox(height: 12),

                      const NotificationCard(
                        type: NotificationType.reminder,
                        title: 'Event Reminder',
                        showUnreadDot: true,
                        message:
                            'Youth Football Training Day starts tomorrow at 4:00 PM.',
                        timeAgo: '2 hours ago',
                      ),

                      const SizedBox(height: 12),

                      const NotificationCard(
                        type: NotificationType.facility,
                        title: 'Facility Update',
                        message:
                            'Parking area at City Sports Ground will be temporarily unavailable on 22 Sep.',
                        timeAgo: 'Yesterday',
                      ),

                      const SizedBox(height: 12),

                      const NotificationCard(
                        type: NotificationType.cancelled,
                        title: 'Event Cancelled',
                        message:
                            'Community Swimming Meet has been postponed due to maintenance.',
                        timeAgo: '2 days ago',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
