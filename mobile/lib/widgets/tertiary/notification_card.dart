
import 'package:flutter/material.dart';
import '../../models/app_notification_model.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({super.key, required this.notification});

  // Local constants — replace with your app theme if available.
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF6B7585);
  static const Color _timeColor = Color(0xFFA3AAB5);
  static const Color _border = Color(0xFFE7EAF0);

  @override
  Widget build(BuildContext context) {
    final accent = notification.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // ClipRRect keeps the accent bar's square edges inside the
      // card's rounded corners.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(notification.icon, size: 16, color: accent),
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
                                    notification.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: _heading,
                                    ),
                                  ),
                                ),
                                if (notification.showDot) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: accent,
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
                                fontSize: 12,
                                color: _subtext,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.timeAgo,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: _timeColor,
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