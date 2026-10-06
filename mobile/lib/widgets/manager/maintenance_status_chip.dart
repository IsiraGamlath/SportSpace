import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

enum MaintenanceStatus {
  available,
  required,
  scheduled,
}

class MaintenanceStatusChip extends StatelessWidget {
  const MaintenanceStatusChip({
    super.key,
    required this.status,
  });

  final MaintenanceStatus status;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: style.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: TextStyle(
              color: style.text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _styleFor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.available:
        return const _StatusStyle(
          label: 'Available',
          background: ManagerColors.greenSoft,
          text: ManagerColors.green,
          dot: ManagerColors.green,
        );
      case MaintenanceStatus.required:
        return const _StatusStyle(
          label: 'Maintenance Required',
          background: ManagerColors.amberSoft,
          text: ManagerColors.amber,
          dot: ManagerColors.amber,
        );
      case MaintenanceStatus.scheduled:
        return const _StatusStyle(
          label: 'Scheduled Maintenance',
          background: ManagerColors.amberSoft,
          text: ManagerColors.amber,
          dot: ManagerColors.amber,
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
