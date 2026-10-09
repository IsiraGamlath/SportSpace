import 'package:flutter/material.dart';

import '../../models/app_notification_model.dart';
import '../../services/app_services.dart';
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
  void initState() {
    super.initState();
    appServices.notificationService.addListener(_onChanged);
    appServices.notificationService.fetchFromBackend('facilityManager');
  }

  @override
  void dispose() {
    appServices.notificationService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<AppNotification> get _filteredNotifications {
    final list = appServices.notificationService
        .getNotificationsForRole('facilityManager');
    final filter = _filters[_selectedFilter];
    switch (filter) {
      case 'Events':
        return list
            .where((n) => n.category == NotificationCategory.event)
            .toList();
      case 'Schedules':
        return list
            .where((n) => n.category == NotificationCategory.schedule)
            .toList();
      case 'Facilities':
        return list
            .where((n) => n.category == NotificationCategory.facility)
            .toList();
      case 'All':
      default:
        return list;
    }
  }

  NotificationType _resolveType(AppNotification n) {
    if (n.category == NotificationCategory.schedule) {
      return NotificationType.schedule;
    }
    if (n.category == NotificationCategory.facility) {
      return NotificationType.facility;
    }
    final lowerTitle = n.title.toLowerCase();
    if (lowerTitle.contains('cancel') || lowerTitle.contains('unpaid')) {
      return NotificationType.cancelled;
    }
    return NotificationType.reminder;
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filteredNotifications;

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
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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

                      if (notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No notifications in this category',
                              style: TextStyle(
                                color: ManagerColors.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ...notifications.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NotificationCard(
                              type: _resolveType(item),
                              title: item.title,
                              showUnreadDot: item.showDot,
                              message: item.description,
                              timeAgo: item.timeAgo,
                            ),
                          ),
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
