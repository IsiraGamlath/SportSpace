import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

enum ScheduleStatus { confirmed, paid, pendingPayment }

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  final String time;
  final String title;
  final String subtitle;
  final ScheduleStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ManagerColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ManagerColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$time — $title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(minWidth: 70),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: statusInfo.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusInfo.dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusInfo.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusInfo.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
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

  _StatusInfo _statusInfo(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.confirmed:
        return const _StatusInfo(
          label: 'Confirmed',
          background: ManagerColors.tealSoft,
          dot: ManagerColors.teal,
          text: ManagerColors.teal,
        );
      case ScheduleStatus.paid:
        return const _StatusInfo(
          label: 'Paid',
          background: ManagerColors.tealSoft,
          dot: ManagerColors.teal,
          text: ManagerColors.teal,
        );
      case ScheduleStatus.pendingPayment:
        return const _StatusInfo(
          label: 'Pending\nPayment',
          background: ManagerColors.amberSoft,
          dot: ManagerColors.amber,
          text: ManagerColors.amber,
        );
    }
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.background,
    required this.dot,
    required this.text,
  });

  final String label;
  final Color background;
  final Color dot;
  final Color text;
}
