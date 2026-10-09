
import 'package:flutter/material.dart';

import '../../models/app_notification_model.dart';
import '../../services/app_services.dart';
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

  static const List<String> _filters = [
    'All',
    'Events',
    'Schedules',
    'Facilities',
  ];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    appServices.notificationService.addListener(_onChanged);
    appServices.notificationService.fetchFromBackend('communityMember');
  }

  @override
  void dispose() {
    appServices.notificationService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<AppNotification> get _notifications =>
      appServices.notificationService.getNotificationsForRole('communityMember');

  List<AppNotification> get _filteredNotifications {
    final list = _notifications;
    switch (_selectedFilter) {
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
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: _heading,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('community_mark_read_button'),
                    onPressed: () {
                      appServices.notificationService
                          .markAllAsRead('communityMember');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all_rounded,
                        size: 16, color: _heading),
                    label: const Text(
                      'Mark as read',
                      style: TextStyle(
                        color: _heading,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE7EAF0)),
                      ),
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
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return InkWell(
                          key: Key('community_notif_card_${notif.id}'),
                          onTap: () {
                            appServices.notificationService
                                .markAsRead(notif.id);
                          },
                          child: NotificationCard(notification: notif),
                        );
                      },
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