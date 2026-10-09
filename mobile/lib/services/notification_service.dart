import 'package:flutter/material.dart';
import '../models/app_notification_model.dart';
import 'api_service.dart';

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  bool _initialized = false;

  NotificationService() {
    _initDefaults();
  }

  void _initDefaults() {
    _notifications.clear();
    _notifications.addAll([
      const AppNotification(
        id: 'n1',
        title: 'Schedule Updated',
        description:
            'Colombo Community Badminton Open — start time changed from 9:00 AM to 10:00 AM.',
        timeAgo: '10 minutes ago',
        icon: Icons.calendar_today_rounded,
        accentColor: Color(0xFFDF8420),
        category: NotificationCategory.schedule,
        showDot: true,
        targetRole: 'all',
      ),
      const AppNotification(
        id: 'n2',
        title: 'Event Reminder',
        description: 'Youth Football Training Day starts tomorrow at 4:00 PM.',
        timeAgo: '2 hours ago',
        icon: Icons.notifications_none_rounded,
        accentColor: Color(0xFF2E8B57),
        category: NotificationCategory.event,
        showDot: true,
        targetRole: 'all',
      ),
      const AppNotification(
        id: 'n3',
        title: 'Facility Update',
        description:
            'Parking area at City Sports Ground will be temporarily unavailable on 22 Sep.',
        timeAgo: 'Yesterday',
        icon: Icons.location_on_outlined,
        accentColor: Color(0xFFDF8420),
        category: NotificationCategory.facility,
        showDot: false,
        targetRole: 'all',
      ),
      const AppNotification(
        id: 'n4',
        title: 'Event Cancelled',
        description:
            'Community Swimming Meet has been postponed due to maintenance.',
        timeAgo: '2 days ago',
        icon: Icons.flag_rounded,
        accentColor: Color(0xFFE14C4C),
        category: NotificationCategory.event,
        showDot: false,
        targetRole: 'all',
      ),
    ]);
  }

  List<AppNotification> get allNotifications =>
      List.unmodifiable(_notifications);

  List<AppNotification> getNotificationsForRole(String role) {
    return _notifications.where((n) {
      if (n.targetRole == null || n.targetRole == 'all') return true;
      return n.targetRole == role;
    }).toList();
  }

  Future<void> fetchFromBackend([String? role]) async {
    try {
      final backendList = await ApiService.fetchNotifications(role: role);
      if (backendList.isNotEmpty) {
        final parsed = backendList.map((e) => AppNotification.fromJson(e)).toList();
        _notifications.clear();
        _notifications.addAll(parsed);
        notifyListeners();
      }
    } catch (_) {
      // Graceful offline fallback
    }
  }

  AppNotification dispatchNotification({
    required List<String> targetRoles,
    String? userId,
    required String title,
    required String message,
    required NotificationCategory category,
    Color? accentColor,
    IconData? icon,
    String timeAgo = 'Just now',
    bool showDot = true,
  }) {
    final id = 'notif_${DateTime.now().millisecondsSinceEpoch}_${_notifications.length}';
    final resolvedColor = accentColor ??
        (category == NotificationCategory.schedule
            ? const Color(0xFFDF8420)
            : (title.toLowerCase().contains('cancel') || title.toLowerCase().contains('unpaid')
                ? const Color(0xFFE14C4C)
                : const Color(0xFF2E8B57)));

    final resolvedIcon = icon ??
        (category == NotificationCategory.schedule
            ? Icons.calendar_today_rounded
            : (category == NotificationCategory.facility
                ? Icons.location_on_outlined
                : (title.toLowerCase().contains('cancel')
                    ? Icons.flag_rounded
                    : Icons.notifications_none_rounded)));

    // Create notifications for specified roles
    final notification = AppNotification(
      id: id,
      title: title,
      description: message,
      timeAgo: timeAgo,
      icon: resolvedIcon,
      accentColor: resolvedColor,
      category: category,
      showDot: showDot,
      targetRole: targetRoles.length == 1 ? targetRoles.first : 'all',
    );

    // Insert at front
    _notifications.insert(0, notification);
    notifyListeners();

    // Async push to backend
    for (final role in targetRoles) {
      ApiService.createNotification({
        'targetRole': role,
        'userId': userId,
        'category': category.name,
        'title': title,
        'message': message,
        'accentColor': resolvedColor == const Color(0xFF2E8B57)
            ? 'green'
            : (resolvedColor == const Color(0xFFE14C4C) ? 'red' : 'orange'),
      }).catchError((_) => <String, dynamic>{});
    }

    return notification;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _notifications[index];
      _notifications[index] = AppNotification(
        id: old.id,
        title: old.title,
        description: old.description,
        timeAgo: old.timeAgo,
        icon: old.icon,
        accentColor: old.accentColor,
        category: old.category,
        showDot: false,
        targetRole: old.targetRole,
      );
      notifyListeners();
      ApiService.markNotificationAsRead(id).catchError((_) => false);
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _initDefaults();
    notifyListeners();
  }
}
