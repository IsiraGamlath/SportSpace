// lib/models/app_notification_model.dart
//
// An in-app notification shown on role-based Notifications screens.
// [category] drives All/Events/Schedules/Facilities filter chips.

import 'package:flutter/material.dart';

enum NotificationCategory { event, schedule, facility }

class AppNotification {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color accentColor;
  final NotificationCategory category;
  final bool showDot;
  final String? targetRole;

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.accentColor,
    required this.category,
    this.showDot = true,
    this.targetRole,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] as String? ?? 'event').toLowerCase();
    final title = json['title'] as String? ?? 'Notification';
    final desc = json['message'] as String? ?? json['description'] as String? ?? '';
    final timeAgo = json['timeAgo'] as String? ?? 'Recently';
    final accentStr = (json['accentColor'] as String? ?? '').toLowerCase();

    NotificationCategory category;
    if (catStr.contains('schedule')) {
      category = NotificationCategory.schedule;
    } else if (catStr.contains('facility')) {
      category = NotificationCategory.facility;
    } else {
      category = NotificationCategory.event;
    }

    final accentColor = _colorFor(accentStr, title);
    final icon = _iconFor(catStr, title);
    final isRead = json['isRead'] as bool? ?? false;

    return AppNotification(
      id: json['id'] as String? ?? json['_id'] as String? ?? UniqueKey().toString(),
      title: title,
      description: desc,
      timeAgo: timeAgo,
      icon: icon,
      accentColor: accentColor,
      category: category,
      showDot: !isRead,
      targetRole: json['targetRole'] as String?,
    );
  }

  static Color _colorFor(String accentStr, String title) {
    final lowerTitle = title.toLowerCase();
    if (accentStr == 'green' || lowerTitle.contains('reminder') || lowerTitle.contains('confirm')) {
      return const Color(0xFF2E8B57);
    }
    if (accentStr == 'red' || lowerTitle.contains('cancel') || lowerTitle.contains('unpaid')) {
      return const Color(0xFFE14C4C);
    }
    if (accentStr == 'teal') {
      return const Color(0xFF1D7A6B);
    }
    return const Color(0xFFDF8420); // Orange
  }

  static IconData _iconFor(String cat, String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('schedule') || lowerTitle.contains('time')) {
      return Icons.calendar_today_rounded;
    }
    if (lowerTitle.contains('reminder')) {
      return Icons.notifications_none_rounded;
    }
    if (lowerTitle.contains('cancel') || lowerTitle.contains('postpone')) {
      return Icons.flag_rounded;
    }
    if (lowerTitle.contains('facility') ||
        lowerTitle.contains('ground') ||
        lowerTitle.contains('court')) {
      return Icons.location_on_outlined;
    }
    if (lowerTitle.contains('pay') || lowerTitle.contains('booking')) {
      return lowerTitle.contains('unpaid')
          ? Icons.highlight_off_rounded
          : Icons.check_circle_outline_rounded;
    }
    if (lowerTitle.contains('request') || lowerTitle.contains('enquiry')) {
      return Icons.mark_email_read_outlined;
    }
    if (cat == 'schedule') {
      return Icons.calendar_today_rounded;
    }
    if (cat == 'facility') {
      return Icons.location_on_outlined;
    }
    return Icons.notifications_none_rounded;
  }
}