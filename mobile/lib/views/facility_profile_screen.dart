import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'review_screen.dart';
import 'slot_selection_screen.dart';

class FacilityProfileScreen extends StatelessWidget {
  const FacilityProfileScreen({
    super.key,
    required this.name,
    required this.sport,
    required this.distance,
    required this.rating,
    required this.price,
    required this.color,
    required this.icon,
    this.imagePath,
  });

  final String name;
  final String sport;
  final String distance;
  final String rating;
  final int price;
  final Color color;
  final IconData icon;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummary(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  _buildSports(),
                  const SizedBox(height: 16),
                  _buildAmenities(),
                  const SizedBox(height: 16),
                  _buildAccessibility(),
                  const SizedBox(height: 18),
                  _buildDetailsLink(),
                  const SizedBox(height: 18),
                  _buildReviews(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SlotSelectionScreen(
                  facilityName: name,
                  sport: sport,
                  location: 'Colombo, Sri Lanka',
                )),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Check Availability',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imagePath == null
              ? Container(
                  color: color,
                  child: Icon(icon, color: Colors.white70, size: 82),
                )
              : Image.network(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: color,
                    child: Icon(icon, color: Colors.white70, size: 82),
                  ),
                ),
          Positioned(
            top: 12,
            left: 18,
            child: _roundAction(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 12,
            right: 18,
            child: Row(
              children: [
                _roundAction(icon: Icons.share_outlined, onTap: () {}),
                const SizedBox(width: 10),
                _roundAction(icon: Icons.favorite_border, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundAction({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF4A340), size: 15),
            const SizedBox(width: 4),
            Text(
              '$rating (126 reviews)',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4),
            Text(
              'Colombo, Sri Lanka',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _infoTile(Icons.phone_outlined, 'Contact', '011 234 5678'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoTile(Icons.access_time, 'Open now', '8AM–10PM'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 15),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      'A well-maintained multi-sport facility in the heart of Colombo, offering indoor courts, professional coaching on request, and easy access to public transport.',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        height: 1.45,
      ),
    );
  }

  Widget _buildSports() {
    return _section(
      'Sports available',
      Wrap(
        spacing: 8,
        children: [_tag(sport), _tag('Basketball'), _tag('Tennis')],
      ),
    );
  }

  Widget _buildAmenities() {
    return _section(
      'Amenities',
      const Wrap(
        runSpacing: 11,
        children: [
          _FeatureItem(Icons.local_parking_outlined, 'Parking'),
          _FeatureItem(Icons.meeting_room_outlined, 'Changing rooms'),
          _FeatureItem(Icons.settings_outlined, 'Equipment rental'),
          _FeatureItem(Icons.local_drink_outlined, 'Refreshments'),
        ],
      ),
    );
  }

  Widget _buildAccessibility() {
    return _section(
      'Accessibility',
      const Column(
        children: [
          _FeatureItem(Icons.accessible_forward, 'Accessible entrance'),
          SizedBox(height: 10),
          _FeatureItem(Icons.local_parking_outlined, 'Accessible parking'),
          SizedBox(height: 10),
          _FeatureItem(Icons.check, 'Accessible facilities throughout'),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailsLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          Text(
            'Full contact & accessibility details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 17),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchReviews(name),
      builder: (context, snapshot) {
        final reviews = snapshot.data?['reviews'] as List<Review>? ?? [];
        final count = snapshot.data?['reviewCount'] as int? ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(facilityName: name),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: Text(
                      'See all ($count)',
                      style: const TextStyle(
                        color: AppColors.primaryTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (snapshot.hasError || reviews.isEmpty)
              _reviewContainer(
                const Text(
                  'No reviews yet. Be the first player to share your experience.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              )
            else
              ...reviews.take(3).map(_reviewCard),
          ],
        );
      },
    );
  }

  Widget _reviewContainer(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }

  Widget _reviewCard(Review review) {
    final initials = review.userName.trim().isEmpty
        ? 'P'
        : review.userName
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _reviewContainer(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.darkNavy,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${'★' * review.rating}${'☆' * (5 - review.rating)}',
                    style: const TextStyle(
                      color: Color(0xFFF4A340),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    review.comment,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.4,
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
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          Icon(icon, color: AppColors.available, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
