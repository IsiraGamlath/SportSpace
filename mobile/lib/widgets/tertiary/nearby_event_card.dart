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
import 'package:firebase_auth/firebase_auth.dart';
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

  String _getCurrentUserId() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        return user.uid;
      }
    } catch (_) {}
    return 'community_user';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: (appServices.eventRepository is Listenable)
          ? (appServices.eventRepository as Listenable)
          : appServices.bookmarkService,
      builder: (context, _) {
        final liveEvent = appServices.eventRepository.getEventById(event.id) ?? event;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                      child: EventImage(imageUrl: liveEvent.imageUrl),
                    ),
                    Positioned(top: 10, right: 10, child: _statusBadge(liveEvent)),
                    if (showActions)
                      Positioned(top: 10, left: 10, child: _quickActions(liveEvent)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveEvent.title,
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
                            liveEvent.sport,
                            style: const TextStyle(fontSize: 12.5, color: _subColor),
                          ),
                          _dot(),
                          Text(
                            liveEvent.date,
                            style: const TextStyle(fontSize: 12.5, color: _subColor),
                          ),
                          _dot(),
                          Flexible(
                            child: Text(
                              liveEvent.time,
                              style: const TextStyle(fontSize: 12.5, color: _subColor),
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
                              liveEvent.location,
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
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFECEFF2)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.group_outlined,
                                      size: 14,
                                      color: liveEvent.isFull
                                          ? const Color(0xFFE14C4C)
                                          : const Color(0xFF1D7A6B),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      liveEvent.isFull
                                          ? 'Full (${liveEvent.participantCount}/${liveEvent.capacity})'
                                          : '${liveEvent.participantCount}/${liveEvent.capacity} Spots',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: liveEvent.isFull
                                            ? const Color(0xFFE14C4C)
                                            : _titleColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: liveEvent.capacity > 0
                                        ? (liveEvent.participantCount / liveEvent.capacity).clamp(0.0, 1.0)
                                        : 0.0,
                                    backgroundColor: const Color(0xFFECEFF3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      liveEvent.isFull
                                          ? const Color(0xFFE14C4C)
                                          : const Color(0xFF1D7A6B),
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          _buildRsvpButton(context, liveEvent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRsvpButton(BuildContext context, NearbyEvent liveEvent) {
    final userId = _getCurrentUserId();
    final isGoing = liveEvent.isParticipating(userId);
    final isFull = liveEvent.isFull;

    if (isGoing) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await appServices.eventRepository.toggleParticipation(liveEvent.id, userId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('RSVP cancelled for "${liveEvent.title}".'),
                  backgroundColor: _titleColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7EC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2E8B57), width: 1.2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF1C7A4C)),
                SizedBox(width: 4),
                Text(
                  'Going',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C7A4C),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD8DEE4), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded, size: 13, color: Color(0xFF8A93A3)),
            SizedBox(width: 4),
            Text(
              'Event Full',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A93A3),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          try {
            await appServices.eventRepository.toggleParticipation(liveEvent.id, userId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('RSVP confirmed for "${liveEvent.title}"!'),
                  backgroundColor: const Color(0xFF1D7A6B),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: const Color(0xFFE14C4C),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF1D7A6B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.how_to_reg_rounded, size: 14, color: Colors.white),
              SizedBox(width: 5),
              Text(
                'RSVP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge([NearbyEvent? customEvent]) {
    final e = customEvent ?? event;
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
            e.status,
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
  Widget _quickActions([NearbyEvent? customEvent]) {
    final e = customEvent ?? event;
    return ListenableBuilder(
      listenable: Listenable.merge([
        appServices.bookmarkService,
        appServices.reminderService,
      ]),
      builder: (context, _) {
        final saved = appServices.bookmarkService.isSaved(e.id);
        final reminded = appServices.reminderService.isSubscribed(e.id);
        return Row(
          children: [
            _actionCircle(
              icon: saved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              active: saved,
              onTap: () => appServices.bookmarkService.toggle(e.id),
            ),
            const SizedBox(width: 6),
            _actionCircle(
              icon: reminded
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              active: reminded,
              onTap: () => appServices.reminderService.toggle(e.id, e),
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
          color: Colors.white.withValues(alpha: 0.92),
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