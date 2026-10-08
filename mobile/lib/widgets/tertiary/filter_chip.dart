
import 'package:flutter/material.dart';

class EventFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final bool showCaret;
  final VoidCallback? onTap;

  const EventFilterChip({
    super.key,
    required this.label,
    this.icon,
    this.isActive = false,
    this.showCaret = false,
    this.onTap,
  });

  // Local constants — replace with your app theme (utils/app_colors.dart)
  // if it exposes equivalents.
  static const Color _activeBg = Color(0xFF0D2B4E);
  static const Color _activeText = Colors.white;
  static const Color _inactiveBg = Colors.white;
  static const Color _inactiveBorder = Color(0xFFE7EAF0);
  static const Color _inactiveText = Color(0xFF4A5568);

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? _activeBg : _inactiveBg;
    final fg = isActive ? _activeText : _inactiveText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: _inactiveBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
            if (showCaret) ...[
              const SizedBox(width: 5),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}