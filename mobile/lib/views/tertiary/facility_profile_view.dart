import 'package:flutter/material.dart';

import '../../widgets/tertiary/event_image.dart';
import 'contact_accessibility_view.dart';
import 'events_view.dart';
import 'facility_details_view.dart';
import 'notifications_view.dart';

class FacilityProfileView extends StatelessWidget {
  final String facilityId;
  final String facilityName;
  final String imageUrl;
  final String status;
  final String cityLocation;
  final String address;
  final String phone;
  final String email;
  final String openingHours;
  final List<String> availableSports;
  final List<FacilityAmenity> amenities;
  final String accessibilityNote;
  final String description;
  final double rating;
  final List<String> upcomingEvents;

  const FacilityProfileView({
    super.key,
    required this.facilityId,
    required this.facilityName,
    required this.imageUrl,
    this.status = 'Open',
    this.cityLocation = '',
    this.address = '',
    this.phone = '+94 11 234 5678',
    this.email = 'info@sportspace.lk',
    this.openingHours = '6:00 AM – 10:00 PM',
    this.availableSports = const [],
    this.amenities = const [],
    this.accessibilityNote = '',
    this.description = '',
    this.rating = 4.8,
    this.upcomingEvents = const [],
  });

  static const Color _background = Color(0xFFF5F6F8);
  static const Color _navy = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _cardBorder = Color(0xFFE7EAF0);
  static const Color _statusBg = Color(0xFFE5F7EC);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1C7A4C);
  static const Color _chipBg = Color(0xFFF0F2F5);

  String get _effectiveDescription {
    if (description.isNotEmpty) return description;
    return 'A premier multi-sport recreational facility in $cityLocation, designed to support amateur and competitive athletes alike. Featuring tournament-standard playing surfaces, climate-controlled practice halls, and professional-grade coaching equipment. All courts and common areas are subject to daily sanitization and periodic facility maintenance for maximum safety and comfort.';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context, topInset),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('About Facility'),
                  const SizedBox(height: 8),
                  _buildDescriptionCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Contact & Location'),
                  const SizedBox(height: 10),
                  _buildContactCard(),
                  const SizedBox(height: 20),
                  if (availableSports.isNotEmpty) ...[
                    _buildSectionTitle('Sports & Activities Available'),
                    const SizedBox(height: 10),
                    _buildSportsList(),
                    const SizedBox(height: 20),
                  ],
                  if (amenities.isNotEmpty) ...[
                    _buildSectionTitle('Amenities & Infrastructure'),
                    const SizedBox(height: 10),
                    _buildAmenitiesGrid(),
                    const SizedBox(height: 20),
                  ],
                  if (accessibilityNote.isNotEmpty) ...[
                    _buildSectionTitle('Accessibility Standards'),
                    const SizedBox(height: 10),
                    _buildAccessibilityCard(),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionTitle('Booking Guidelines & Rates'),
                  const SizedBox(height: 10),
                  _buildRatesAndPoliciesCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Player Reviews'),
                  const SizedBox(height: 10),
                  _buildReviewsSection(),
                  const SizedBox(height: 28),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, double topInset) {
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
          child: _circleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          top: topInset + 12,
          right: 16,
          child: _circleButton(
            icon: Icons.notifications_none_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsView()),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 18,
            decoration: const BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
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
        child: Icon(icon, size: 17, color: _navy),
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 13, color: Color(0xFF2E8B57)),
                    SizedBox(width: 4),
                    Text(
                      'Verified Sports Facility',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        fontWeight: FontWeight.w700,
                        color: _statusText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            facilityName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _navy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF4A340)),
              const SizedBox(width: 4),
              Text(
                '$rating (128 reviews)',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_outlined, size: 14, color: _subtext),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  cityLocation.isNotEmpty ? cityLocation : address,
                  style: const TextStyle(fontSize: 12, color: _subtext),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Text(
        _effectiveDescription,
        style: const TextStyle(
          fontSize: 13,
          height: 1.55,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: address.isNotEmpty ? address : cityLocation,
          ),
          const Divider(height: 20, color: Color(0xFFF1F3F6)),
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Operating Hours',
            value: openingHours,
          ),
          const Divider(height: 20, color: Color(0xFFF1F3F6)),
          _buildInfoRow(
            icon: Icons.phone_rounded,
            label: 'Phone Contact',
            value: phone,
          ),
          const Divider(height: 20, color: Color(0xFFF1F3F6)),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email Enquiries',
            value: email,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3EE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: _subtext),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSportsList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSports.map((sport) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            sport,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _navy,
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
                    color: _navy,
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

  Widget _buildAccessibilityCard() {
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
          const Icon(Icons.accessible_rounded, size: 20, color: _accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              accessibilityNote,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesAndPoliciesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 17, color: _accent),
              SizedBox(width: 8),
              Text(
                'Court & Venue Rates',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Standard Court Hire: LKR 1,500 / hr\n• Peak Hours (5 PM – 9 PM): LKR 2,200 / hr\n• Equipment Rental (Rackets, balls): LKR 300 / session\n• Free cancellation up to 6 hours before slot start time',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _navy,
                child: Text('NR',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nadeesha R. — Verified Player',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _navy),
                  ),
                  Text(
                    '★★★★★  •  2 weeks ago',
                    style: TextStyle(fontSize: 11, color: Color(0xFFF4A340)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Very well maintained facility! Courts were clean, lighting was top notch, and the changing rooms were spotless.',
            style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactAccessibilityView(
                    facilityId: facilityId,
                    facilityName: facilityName,
                    phone: phone,
                    email: email,
                    address: address.isNotEmpty ? address : cityLocation,
                    openingHours: openingHours,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C6E79),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: const Text(
              'Contact & Enquire',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventsView(initialQuery: facilityName),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _accent,
              side: const BorderSide(color: _accent, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: const Text(
              'View Scheduled Events',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
