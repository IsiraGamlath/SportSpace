import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

class ManagerBottomNav extends StatelessWidget {
  const ManagerBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavData(Icons.grid_view_rounded, 'Dashboard'),
      _NavData(Icons.calendar_today_outlined, 'Schedule'),
      _NavData(Icons.access_time_rounded, 'Bookings'),
      _NavData(Icons.handyman_outlined, 'Maintenance'),
      _NavData(Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: ManagerColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        maintainBottomViewPadding: true,
        child: SizedBox(
          height: 64, // Generous height for icons + text + easy tapping
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap?.call(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 23,
                          color: selected ? ManagerColors.teal : ManagerColors.mutedText,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? ManagerColors.navy
                                : ManagerColors.mutedText,
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  const _NavData(this.icon, this.label);

  final IconData icon;
  final String label;
}
