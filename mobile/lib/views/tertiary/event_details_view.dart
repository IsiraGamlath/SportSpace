
import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import '../../widgets/tertiary/event_image.dart';
import 'facility_details_view.dart';
import 'placeholder_view.dart';

class EventDetailsView extends StatelessWidget {
  final NearbyEvent event;

  const EventDetailsView({super.key, required this.event});

  // Local constants — replace with your app theme if available.
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF55606E);
  static const Color _locationColor = Color(0xFF1D7A6B);
  static const Color _tagBg = Color(0xFFE3F3EC);
  static const Color _tagText = Color(0xFF1D7A6B);
  static const Color _statusBg = Color(0xFFE5F7EC);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1C7A4C);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(context, topInset),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: 12),
                  _buildTag(event.sport),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today_outlined, event.date),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time_rounded, event.time),
                  const SizedBox(height: 8),
                  _buildLocationRow(context),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: _subtext,
                      ),
                    ),
                  ],
                  if (event.organizerName.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionTitle('Organizer'),
                    const SizedBox(height: 10),
                    _buildOrganizerCard(context),
                  ],
                  if (event.timeline.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionTitle('Event Timeline'),
                    const SizedBox(height: 10),
                    _buildTimeline(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Buttons live in bottomNavigationBar (not inside the scroll view)
      // so they stay accessible on longer content without needing
      // fixed-height containers anywhere above — and the whole page is
      // scrollable, so nothing clips on smaller screens.
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeaderImage(BuildContext context, double topInset) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: EventImage(imageUrl: event.imageUrl, height: 260),
          ),
          Positioned(
            top: topInset + 12,
            left: 16,
            child: _circleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: topInset + 12,
            right: 16,
            child: _circleIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const TertiaryPlaceholderView(title: 'Notifications'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: _heading),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            event.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _heading,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _tagBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: _tagText,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _subtext),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13.5, color: _subtext)),
        ),
      ],
    );
  }

  /// Location row is tappable — opens the same FacilityDetailsView as
  /// the "View Facility" button, so there's a single consistent place
  /// that logic lives (see _openFacility below).
  Widget _buildLocationRow(BuildContext context) {
    return InkWell(
      onTap: () => _openFacility(context),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              size: 16, color: _locationColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.location,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _locationColor,
                decoration: TextDecoration.underline,
                decorationColor: _locationColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _heading,
      ),
    );
  }

  Widget _buildOrganizerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _locationColor,
            child: Text(
              event.organizerInitials.isNotEmpty
                  ? event.organizerInitials
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.organizerName,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _heading,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          TextButton(
            onPressed: () => _onContactTap(context),
            child: const Text(
              'Contact',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _locationColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Isolated so this is the single place to swap in a real
  /// contact/messaging flow (e.g. open chat, dial, or mailto) later
  /// without touching the rest of the screen.
  void _onContactTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact ${event.organizerName} — coming soon')),
    );
    // TODO(backend): replace with a real contact/messaging action, e.g.
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => ContactOrganizerView(event: event)));
  }

  /// Isolated so Event Details and the location row share one
  /// navigation path to the facility.
  ///
  /// NOTE: openingHours/availableSports/amenities/upcomingEvents are
  /// facility-wide data, not event data — there's no Facility
  /// repository yet, so these are mocked here for now. Replace with a
  /// real facility lookup (by event.facility) once one exists.
  void _openFacility(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilityDetailsView(
          title: event.title,
          imageUrl: event.imageUrl,
          status: event.status,
          cityLocation: 'Colombo, Sri Lanka',
          scheduleTimeRange: event.time,
          scheduleEventTitle: event.title,
          openingHours: '8AM – 10PM',
          availableSports: const ['Badminton', 'Basketball', 'Tennis'],
          amenities: const [
            FacilityAmenity(
                icon: Icons.local_parking_outlined, label: 'Parking'),
            FacilityAmenity(
                icon: Icons.checkroom_outlined, label: 'Changing rooms'),
            FacilityAmenity(
                icon: Icons.local_cafe_outlined, label: 'Refreshments'),
            FacilityAmenity(
                icon: Icons.inventory_2_outlined, label: 'Equipment rental'),
          ],
          upcomingEvents: const [
            'Colombo Community Badminton Open',
            'Youth Training Session',
          ],
          accessibilityNote: 'Accessible entrance & parking on site',
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: event.timeline
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 78,
                    child: Text(
                      item.time,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _heading,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 13, color: _subtext),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  /// Save + Remind Me actions, pinned above the safe-area bottom, plus
  /// the primary "View Facility" CTA. ListenableBuilder re-renders
  /// just this bar when either service's state changes.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EAF0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: Listenable.merge(
              [appServices.bookmarkService, appServices.reminderService],
            ),
            builder: (context, _) {
              final saved = appServices.bookmarkService.isSaved(event.id);
              final reminded =
                  appServices.reminderService.isSubscribed(event.id);

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          appServices.bookmarkService.toggle(event.id),
                      icon: Icon(
                        saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 18,
                      ),
                      label: Text(saved ? 'Saved' : 'Save'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            saved ? const Color(0xFF2E8B57) : _heading,
                        side: BorderSide(
                          color: saved
                              ? const Color(0xFF2E8B57)
                              : const Color(0xFFE7EAF0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          appServices.reminderService.toggle(event.id),
                      icon: Icon(
                        reminded
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        size: 18,
                      ),
                      label: Text(reminded ? 'Reminder On' : 'Remind Me'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: reminded
                            ? const Color(0xFF2E8B57)
                            : const Color(0xFF1C6E79),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openFacility(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C6E79),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Facility',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}