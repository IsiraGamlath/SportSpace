import 'package:flutter/material.dart';

/// Represents a single tab in the Tertiary Stakeholder nav bar.
class TertiaryNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const TertiaryNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Reusable bottom navigation bar for Tertiary Stakeholder (Viewer/Public)
/// screens: Home, Events, Facilities, Notifications, Profile.
class TertiaryNavBar extends StatelessWidget {
  /// Index of the currently selected tab (0-4).
  final int currentIndex;

  /// Called with the tapped tab's index.
  final ValueChanged<int> onItemSelected;

  const TertiaryNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  // Theming constants matching prototype
  static const Color _background = Colors.white;
  static const Color _dividerColor = Color(0xFFECEFF3);
  static const Color _activeColor = Color(0xFF2E8B57);
  static const Color _inactiveColor = Color(0xFF8F9AA8);

  // Fixed tab definitions matching the approved prototype.
  static const List<TertiaryNavItem> _items = [
    TertiaryNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_outlined,
      label: 'Home',
    ),
    TertiaryNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_outlined,
      label: 'Events',
    ),
    TertiaryNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_outlined,
      label: 'Facilities',
    ),
    TertiaryNavItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_none_rounded,
      label: 'Notifications',
    ),
    TertiaryNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: _background,
        border: const Border(
          top: BorderSide(color: _dividerColor, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomInset > 0 ? bottomInset : 10,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isSelected = index == currentIndex;
            return Expanded(
              child: _TertiaryNavTile(
                item: _items[index],
                isSelected: isSelected,
                activeColor: _activeColor,
                inactiveColor: _inactiveColor,
                onTap: () => onItemSelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Single tappable tab: icon + label, with active/inactive styling.
class _TertiaryNavTile extends StatelessWidget {
  final TertiaryNavItem item;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TertiaryNavTile({
    required this.item,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375).clamp(0.9, 1.15);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.08),
        highlightColor: activeColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24 * scale,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}