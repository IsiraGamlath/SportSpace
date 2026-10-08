// lib/models/app_notification_model.dart
//
// An in-app notification shown on the Notifications screen. [category]
// drives the All/Events/Schedules/Facilities filter chips — it reflects
// what the notification is ABOUT, independent of its accent color
// (e.g. both "Event Reminder" and "Event Cancelled" are `event`
// notifications even though one is green and one is red).

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

  const AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.accentColor,
    required this.category,
  });
}