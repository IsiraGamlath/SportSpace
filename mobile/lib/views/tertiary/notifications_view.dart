
import 'package:flutter/material.dart';

import '../../models/app_notification_model.dart';
import '../../utils/tertiary_navigation.dart';
import '../../widgets/tertiary/filter_chip.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/notification_card.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  // Notifications corresponds to index 3 in TertiaryNavBar.
  static const int _tabIndex = 3;

  // Local constants — replace with your app theme if available.
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _orange = Color(0xFFDF8420);
  static const Color _green = Color(0xFF2E8B57);
  static const Color _red = Color(0xFFE14C4C);

  static const List<String> _filters = [
    'All',
    'Events',
    'Schedules',
    'Facilities',
  ];
  String _selectedFilter = 'All';

  // ---------------------------------------------------------------------
  // Dummy data — replace with a notification repository later.
  // ---------------------------------------------------------------------
  static const List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      title: 'Schedule Updated',
      description:
          'Colombo Community Badminton Open — start time changed from '
          '9:00 AM to 10:00 AM.',
      timeAgo: '10 minutes ago',
      icon: Icons.calendar_today_rounded,
      accentColor: _orange,
      category: NotificationCategory.schedule,
    ),
    AppNotification(
      id: 'n2',
      title: 'Event Reminder',
      description: 'Youth Football Training Day starts tomorrow at 4:00 PM.',
      timeAgo: '2 hours ago',
      icon: Icons.notifications_none_rounded,
      accentColor: _green,
      category: NotificationCategory.event,
    ),
    AppNotification(
      id: 'n3',
      title: 'Facility Update',
      description:
          'Parking area at City Sports Ground will be temporarily '
          'unavailable on 22 Sep.',
      timeAgo: 'Yesterday',
      icon: Icons.location_on_outlined,
      accentColor: _orange,
      category: NotificationCategory.facility,
    ),
    AppNotification(
      id: 'n4',
      title: 'Event Cancelled',
      description:
          'Community Swimming Meet has been postponed due to maintenance.',
      timeAgo: '2 days ago',
      icon: Icons.flag_rounded,
      accentColor: _red,
      category: NotificationCategory.event,
    ),
  ];
  // ---------------------------------------------------------------------

  List<AppNotification> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Events':
        return _notifications
            .where((n) => n.category == NotificationCategory.event)
            .toList();
      case 'Schedules':
        return _notifications
            .where((n) => n.category == NotificationCategory.schedule)
            .toList();
      case 'Facilities':
        return _notifications
            .where((n) => n.category == NotificationCategory.facility)
            .toList();
      case 'All':
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: _heading,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: _heading,
                    ),
                  ),
                ],
              ),
            ),
            // Horizontally scrollable so it never overflows on small phones.
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return EventFilterChip(
                    label: filter,
                    isActive: _selectedFilter == filter,
                    onTap: () => setState(() => _selectedFilter = filter),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'No notifications in this category',
                        style: TextStyle(fontSize: 13, color: _subtext),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) =>
                          NotificationCard(notification: notifications[index]),
                    ),
            ),
          ],
        ),
      ),
      // --- Reused global nav bar, not re-implemented here -----------------
      bottomNavigationBar: TertiaryNavBar(
        currentIndex: _tabIndex,
        onItemSelected: (index) => handleTertiaryNavTap(
          context: context,
          tappedIndex: index,
          currentIndex: _tabIndex,
        ),
      ),
    );
  }
}