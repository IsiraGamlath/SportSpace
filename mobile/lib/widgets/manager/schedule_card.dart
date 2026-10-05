import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

enum ScheduleCardStatus {
  booked,
  available,
  pending,
  blocked,
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.time,
    required this.title,
    required this.status,
    this.subtitle,
    this.onTap,
  });

  final String time;
  final String title;
  final String? subtitle;
  final ScheduleCardStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _styleFor(status);
    final isBlocked = status == ScheduleCardStatus.blocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ManagerColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBlocked ? const Color(0xFFCED8E1) : ManagerColors.border,
            width: 1,
            style: BorderStyle.solid,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ManagerColors.navyDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: ManagerColors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusStyle.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status != ScheduleCardStatus.blocked) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusStyle.dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    statusStyle.label,
                    style: TextStyle(
                      color: statusStyle.text,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusStyle _styleFor(ScheduleCardStatus status) {
    switch (status) {
      case ScheduleCardStatus.booked:
        return const _StatusStyle(
          label: 'Booked',
          background: ManagerColors.redSoft,
          text: ManagerColors.red,
          dot: ManagerColors.red,
        );
      case ScheduleCardStatus.available:
        return const _StatusStyle(
          label: 'Available',
          background: ManagerColors.greenSoft,
          text: ManagerColors.green,
          dot: ManagerColors.green,
        );
      case ScheduleCardStatus.pending:
        return const _StatusStyle(
          label: 'Pending',
          background: ManagerColors.orangeSoft,
          text: ManagerColors.orange,
          dot: ManagerColors.orange,
        );
      case ScheduleCardStatus.blocked:
        return const _StatusStyle(
          label: 'Blocked',
          background: ManagerColors.blockedSoft,
          text: ManagerColors.blockedText,
          dot: ManagerColors.blockedText,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.background,
    required this.text,
    required this.dot,
  });

  final String label;
  final Color background;
  final Color text;
  final Color dot;
}
