import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

enum NotificationType {
  schedule,
  reminder,
  facility,
  cancelled,
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.showUnreadDot = false,
  });

  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final bool showUnreadDot;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: ManagerColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ManagerColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: style.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              size: 20,
              color: style.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: ManagerColors.navyDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (showUnreadDot) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: style.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: ManagerColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: ManagerColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _NotificationStyle _styleFor(NotificationType type) {
    switch (type) {
      case NotificationType.schedule:
        return const _NotificationStyle(
          accent: ManagerColors.orange,
          icon: Icons.calendar_today_outlined,
        );
      case NotificationType.reminder:
        return const _NotificationStyle(
          accent: ManagerColors.green,
          icon: Icons.notifications_none_rounded,
        );
      case NotificationType.facility:
        return const _NotificationStyle(
          accent: ManagerColors.orange,
          icon: Icons.location_on_outlined,
        );
      case NotificationType.cancelled:
        return const _NotificationStyle(
          accent: ManagerColors.red,
          icon: Icons.error_outline_rounded,
        );
    }
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.accent,
    required this.icon,
  });

  final Color accent;
  final IconData icon;
}
