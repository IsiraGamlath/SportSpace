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
        final seen = <String>{};
        final unique = <AppNotification>[];
        for (final n in parsed) {
          final key = '${n.targetRole ?? "all"}_${n.title.toLowerCase().trim()}_${n.description.toLowerCase().trim()}';
          if (seen.add(key)) {
            unique.add(n);
          }
        }
        _notifications.clear();
        _notifications.addAll(unique);
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

    // Create a notification for each target role so roles are strictly isolated without double notifications
    AppNotification? primaryNotification;
    for (final role in targetRoles) {
      final existingIndex = _notifications.indexWhere((n) {
        return (n.targetRole == role || n.targetRole == 'all') &&
            n.title.toLowerCase().trim() == title.toLowerCase().trim() &&
            n.description.toLowerCase().trim() == message.toLowerCase().trim();
      });
      if (existingIndex != -1) {
        primaryNotification ??= _notifications[existingIndex];
        continue;
      }

      final roleNotification = AppNotification(
        id: '${id}_$role',
        title: title,
        description: message,
        timeAgo: timeAgo,
        icon: resolvedIcon,
        accentColor: resolvedColor,
        category: category,
        showDot: showDot,
        targetRole: role,
      );
      _notifications.insert(0, roleNotification);
      primaryNotification ??= roleNotification;
    }

    notifyListeners();
    return primaryNotification ??
        AppNotification(
          id: id,
          title: title,
          description: message,
          timeAgo: timeAgo,
          icon: resolvedIcon,
          accentColor: resolvedColor,
          category: category,
          showDot: showDot,
          targetRole: targetRoles.isNotEmpty ? targetRoles.first : 'all',
        );
  }

  int unreadCountForRole(String role) {
    return _notifications.where((n) {
      final matchesRole =
          n.targetRole == null || n.targetRole == 'all' || n.targetRole == role;
      return matchesRole && n.showDot;
    }).length;
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

  void markAllAsRead([String? role]) {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      final matchesRole = role == null ||
          n.targetRole == null ||
          n.targetRole == 'all' ||
          n.targetRole == role;
      if (matchesRole && n.showDot) {
        _notifications[i] = AppNotification(
          id: n.id,
          title: n.title,
          description: n.description,
          timeAgo: n.timeAgo,
          icon: n.icon,
          accentColor: n.accentColor,
          category: n.category,
          showDot: false,
          targetRole: n.targetRole,
        );
        changed = true;
        ApiService.markNotificationAsRead(n.id).catchError((_) => false);
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _initDefaults();
    notifyListeners();
  }
}
