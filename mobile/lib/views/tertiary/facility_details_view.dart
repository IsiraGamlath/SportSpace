// lib/views/tertiary/facility_details_view.dart
//
// Facility information screen, reached from Event Details' "View
// Facility" action and the tappable location row.
//
// SCOPE NOTE: per instruction, this is screen/layout ONLY — nothing
// here is wired to real navigation or actions yet. The primary CTA
// button is rendered with an empty/no-op onPressed() (so it keeps its
// full active styling rather than looking disabled), and the
// "Upcoming Events" rows / sport chips / amenities are plain
// non-interactive widgets (no InkWell/GestureDetector). Wire up real
// behavior in a follow-up pass once there's somewhere for these to go.
//
// Data-driven: every section is built from constructor parameters, not
// hard-coded — the event_details_view.dart call site currently passes
// mock facility-wide data (opening hours, amenities, etc.) since no
// dedicated Facility model/repository exists in the project yet.

import 'package:flutter/material.dart';
import '../../widgets/tertiary/event_image.dart';
import 'contact_accessibility_view.dart';
import 'facility_profile_view.dart';
import 'notifications_view.dart';

class FacilityAmenity {
  final IconData icon;
  final String label;
  const FacilityAmenity({required this.icon, required this.label});
}

class FacilityDetailsView extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final String cityLocation;
  final String scheduleTimeRange;
  final String scheduleEventTitle;
  final String openingHours;
  final List<String> availableSports;
  final List<FacilityAmenity> amenities;
  final List<String> upcomingEvents;
  final String accessibilityNote;

  // Passed straight through to Screen 2 (ContactAccessibilityView)
  // when "View full facility profile →" is tapped.
  final String facilityId;
  final String facilityName;
  final String phone;
  final String email;
  final String address;

  const FacilityDetailsView({
    super.key,
    required this.title,
    required this.imageUrl,
    this.status = 'Open',
    this.cityLocation = '',
    this.scheduleTimeRange = '',
    this.scheduleEventTitle = '',
    this.openingHours = '',
    this.availableSports = const [],
    this.amenities = const [],
    this.upcomingEvents = const [],
    this.accessibilityNote = '',
    this.facilityId = '',
    this.facilityName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  // Local constants — replace with your app theme if available.
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _statusBg = Color(0xFFE5F7EC);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1C7A4C);
  static const Color _chipBg = Color(0xFFF0F2F5);
  static const Color _cardBorder = Color(0xFFE7EAF0);
  static const Color _ctaColor = Color(0xFF1C6E79);

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
            Container(
              // The rounded "sheet" overlap is drawn by the white strip at
              // the bottom of the header image (see _buildHeaderImage).
              // Container asserts margin is non-negative, so a negative
              // margin here crashes in debug mode.
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  if (cityLocation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildLocationRow(),
                  ],
                  const SizedBox(height: 20),
                  if (scheduleTimeRange.isNotEmpty ||
                      openingHours.isNotEmpty) ...[
                    _sectionTitle("Today's Public Schedule"),
                    const SizedBox(height: 10),
                    if (scheduleTimeRange.isNotEmpty) _buildScheduleCard(),
                    if (scheduleTimeRange.isNotEmpty &&
                        openingHours.isNotEmpty)
                      const SizedBox(height: 10),
                    if (openingHours.isNotEmpty) _buildOpeningHoursCard(),
                    const SizedBox(height: 24),
                  ],
                  if (availableSports.isNotEmpty) ...[
                    _sectionTitle('Sports available'),
                    const SizedBox(height: 10),
                    _buildSportsChips(),
                    const SizedBox(height: 24),
                  ],
                  if (amenities.isNotEmpty) ...[
                    _sectionTitle('Amenities'),
                    const SizedBox(height: 12),
                    _buildAmenitiesGrid(),
                    const SizedBox(height: 24),
                  ],
                  if (upcomingEvents.isNotEmpty) ...[
                    _sectionTitle('Upcoming Events'),
                    const SizedBox(height: 10),
                    _buildUpcomingEventsList(),
                    const SizedBox(height: 24),
                  ],
                  if (accessibilityNote.isNotEmpty) ...[
                    _sectionTitle('Accessibility'),
                    const SizedBox(height: 10),
                    _buildAccessibilityRow(),
                    const SizedBox(height: 28),
                  ],
                  _buildContactButton(context),
                  const SizedBox(height: 14),
                  _buildViewProfileLink(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context, double topInset) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: EventImage(imageUrl: imageUrl, height: 240),
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
              MaterialPageRoute(builder: (_) => const NotificationsView()),
            ),
          ),
        ),
        // White rounded strip across the image's bottom edge — gives the
        // "sheet overlapping the photo" look without a negative margin.
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
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
            title,
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
                status,
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

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 15, color: _subtext),
        const SizedBox(width: 6),
        Text(cityLocation, style: const TextStyle(fontSize: 13, color: _subtext)),
      ],
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

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_available_outlined, size: 18, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: scheduleTimeRange),
                  if (scheduleEventTitle.isNotEmpty)
                    TextSpan(
                      text: ' — $scheduleEventTitle',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _subtext,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Opening hours',
                  style: TextStyle(fontSize: 12, color: _subtext),
                ),
                const SizedBox(height: 2),
                Text(
                  openingHours,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _heading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableSports.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            sport,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _heading,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: amenities.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              Icon(amenity.icon, size: 18, color: _accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  amenity.label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _heading,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingEventsList() {
    return Column(
      children: upcomingEvents.map((eventTitle) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  eventTitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _heading,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFC3C9D3)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessibilityRow() {
    return Row(
      children: [
        const Icon(Icons.accessible_rounded, size: 18, color: _accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            accessibilityNote,
            style: const TextStyle(
              fontSize: 13,
              color: _heading,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToContactAccessibility(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactAccessibilityView(
          facilityId: facilityId.isNotEmpty ? facilityId : title,
          facilityName: facilityName.isNotEmpty ? facilityName : title,
          phone: phone,
          email: email,
          address: address.isNotEmpty ? address : cityLocation,
          openingHours: openingHours,
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToContactAccessibility(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _ctaColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        child: const Text(
          'Contact & view Accessibility',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _navigateToFacilityProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilityProfileView(
          facilityId: facilityId.isNotEmpty ? facilityId : title,
          facilityName: facilityName.isNotEmpty ? facilityName : title,
          imageUrl: imageUrl,
          status: status,
          cityLocation: cityLocation,
          address: address.isNotEmpty ? address : cityLocation,
          phone: phone.isNotEmpty ? phone : '+94 11 234 5678',
          email: email.isNotEmpty ? email : 'info@sportspace.lk',
          openingHours: openingHours.isNotEmpty
              ? openingHours
              : '6:00 AM – 10:00 PM',
          availableSports: availableSports,
          amenities: amenities,
          accessibilityNote: accessibilityNote,
          upcomingEvents: upcomingEvents,
        ),
      ),
    );
  }

  Widget _buildViewProfileLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _navigateToFacilityProfile(context),
        child: const Text(
          'View full facility profile →',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _accent,
          ),
        ),
      ),
    );
  }
}