// lib/widgets/tertiary/nearby_event_card.dart
//
// Reusable event card (image, status badge, title, sport/date/time,
// location). Used on Home ("Nearby & Recommended") and the Events
// screen — single shared implementation, not duplicated per screen.
//
// Optional Save/Remind quick-action icons (showActions: true) read
// live state from BookmarkService/ReminderService via
// services/app_services.dart, so the icon state is always correct no
// matter which screen the card is shown on. Off by default so the
// Home screen's existing appearance is unchanged.

import 'package:flutter/material.dart';
import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import 'event_image.dart';

class NearbyEventCard extends StatelessWidget {
  final NearbyEvent event;
  final VoidCallback? onTap;
  final bool showActions;

  const NearbyEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showActions = false,
  });

  // Local constants — replace with your app theme if available.
  static const Color _cardBg = Colors.white;
  static const Color _titleColor = Color(0xFF0F2A44);
  static const Color _subColor = Color(0xFF8A93A3);
  static const Color _locationColor = Color(0xFF1D7A6B);
  static const Color _dotColor = Color(0xFFC3C9D3);
  static const Color _statusBg = Color(0xFFE5F7EC);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1C7A4C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: EventImage(imageUrl: event.imageUrl),
                ),
                Positioned(top: 10, right: 10, child: _statusBadge()),
                if (showActions)
                  Positioned(top: 10, left: 10, child: _quickActions()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        event.sport,
                        style: const TextStyle(fontSize: 12.5, color: _subColor),
                      ),
                      _dot(),
                      Text(
                        event.date,
                        style: const TextStyle(fontSize: 12.5, color: _subColor),
                      ),
                      _dot(),
                      Flexible(
                        child: Text(
                          event.time,
                          style:
                              const TextStyle(fontSize: 12.5, color: _subColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: _locationColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _locationColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _statusDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            event.status,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusText,
            ),
          ),
        ],
      ),
    );
  }

  /// Rebuilds only this small row when bookmark/reminder state changes
  /// — ListenableBuilder is built into Flutter, no extra package needed.
  Widget _quickActions() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        appServices.bookmarkService,
        appServices.reminderService,
      ]),
      builder: (context, _) {
        final saved = appServices.bookmarkService.isSaved(event.id);
        final reminded = appServices.reminderService.isSubscribed(event.id);
        return Row(
          children: [
            _actionCircle(
              icon: saved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              active: saved,
              onTap: () => appServices.bookmarkService.toggle(event.id),
            ),
            const SizedBox(width: 6),
            _actionCircle(
              icon: reminded
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              active: reminded,
              onTap: () => appServices.reminderService.toggle(event.id),
            ),
          ],
        );
      },
    );
  }

  Widget _actionCircle({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? const Color(0xFF2E8B57) : const Color(0xFF8A93A3),
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Container(
          width: 3,
          height: 3,
          decoration:
              const BoxDecoration(color: _dotColor, shape: BoxShape.circle),
        ),
      );
}