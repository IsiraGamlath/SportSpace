import 'package:flutter/material.dart';

import '../models/app_notification_model.dart';
import '../services/app_services.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'my_bookings_screen.dart';

class PlayerNotificationsView extends StatefulWidget {
  const PlayerNotificationsView({super.key});

  @override
  State<PlayerNotificationsView> createState() =>
      _PlayerNotificationsViewState();
}

class _PlayerNotificationsViewState extends State<PlayerNotificationsView> {
  static const int _tabIndex = 3;

  static const Color _navy = Color(0xFF0F2A44);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _cardBorder = Color(0xFFE6EBF0);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _timeMuted = Color(0xFF94A3B8);

  final List<String> _filters = const [
    'All',
    'Events',
    'Schedules',
    'Facilities',
  ];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    appServices.notificationService.addListener(_onNotificationsChanged);
    appServices.notificationService.fetchFromBackend('player');
  }

  @override
  void dispose() {
    appServices.notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) setState(() {});
  }

  List<AppNotification> get _filteredNotifications {
    final list = appServices.notificationService.getNotificationsForRole('player');
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

  void _onNavTap(int index) {
    if (index == _tabIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExploreScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        size: 24,
                        color: _navy,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            // Filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return InkWell(
                    key: Key('player_filter_$filter'),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _navy : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _navy : _cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _navy,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Notifications card list
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications in this category',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _PlayerNotificationCard(notification: item);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tabIndex,
        onItemSelected: _onNavTap,
      ),
    );
  }
}

class _PlayerNotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _PlayerNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left colored accent stripe
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: notification.accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with subtle circular background
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: notification.accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          notification.icon,
                          size: 19,
                          color: notification.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      color: Color(0xFF0F2A44),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                if (notification.showDot) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: notification.accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.description,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.timeAgo,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
