import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/review.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../utils/app_colors.dart';
import 'review_screen.dart';
import 'slot_selection_screen.dart';

class FacilityProfileScreen extends StatefulWidget {
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
  State<FacilityProfileScreen> createState() => _FacilityProfileScreenState();
}

class _FacilityProfileData {
  const _FacilityProfileData({
    required this.facility,
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
    this.reviewsError,
  });

  final Map<String, dynamic>? facility;
  final double averageRating;
  final int reviewCount;
  final List<Review> reviews;
  final String? reviewsError;
}

class _FacilityProfileScreenState extends State<FacilityProfileScreen> {
  late Future<_FacilityProfileData> _profileFuture;
  int _selectedPhotoIndex = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorites = await FavoritesService.loadFavorites();
    if (mounted) setState(() => _isFavorite = favorites.contains(widget.name));
  }

  Future<void> _toggleFavorite(Map<String, dynamic>? facility) async {
    final facilityName = _displayName(facility);
    try {
      final isFavorite = await FavoritesService.toggleFavorite(facilityName);
      if (!mounted) return;
      setState(() => _isFavorite = isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? '$facilityName added to your favourites'
                : '$facilityName removed from your favourites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your favourites')),
      );
    }
  }

  Future<void> _shareFacility(Map<String, dynamic>? facility) async {
    final facilityName = _displayName(facility);
    final location = facility?['location']?.toString().trim();
    final sport = _displaySport(facility);
    final rate = facility?['hourlyRate']?.toString() ?? widget.price.toString();
    final photos = _facilityPhotos(facility);
    final photoUrl = photos.isEmpty ? null : photos.first;
    final shareText = [
      'Check out $facilityName on SportSpace.',
      'Sport: $sport',
      if (location?.isNotEmpty == true) 'Location: $location',
      'Hourly rate: Rs. $rate/hr',
      if (photoUrl != null) 'Photo: $photoUrl',
    ].join('\n');

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText, title: facilityName),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share this facility')),
      );
    }
  }

  Future<_FacilityProfileData> _loadProfile() async {
    final facility = await ApiService.fetchFacilityByName(widget.name);
    final facilityName = facility?['name']?.toString() ?? widget.name;
    try {
      final reviewPayload = await ApiService.fetchReviews(facilityName);
      return _FacilityProfileData(
        facility: facility,
        averageRating: (reviewPayload['averageRating'] as num?)?.toDouble() ?? 0,
        reviewCount: (reviewPayload['reviewCount'] as num?)?.toInt() ?? 0,
        reviews: (reviewPayload['reviews'] as List?)?.whereType<Review>().toList() ?? [],
      );
    } catch (error) {
      return _FacilityProfileData(
        facility: facility,
        averageRating: 0,
        reviewCount: 0,
        reviews: const [],
        reviewsError: error.toString(),
      );
    }
  }

  String _displayName(Map<String, dynamic>? facility) =>
      facility?['name']?.toString() ?? widget.name;

  String _displaySport(Map<String, dynamic>? facility) {
    final sports = _stringList(facility?['availableSports']);
    if (sports.isNotEmpty) return sports.first;
    return facility?['type']?.toString() ?? widget.sport;
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  String _ratingSummary(double averageRating, int reviewCount) {
    if (reviewCount == 0) return 'No reviews yet';
    return '${averageRating.toStringAsFixed(1)} ($reviewCount reviews)';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FacilityProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final profile = snapshot.data;
        final facility = profile?.facility;
        final reviews = profile?.reviews ?? [];
        final reviewCount = profile?.reviewCount ?? 0;
        final averageRating = profile?.averageRating ?? 0;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            bottom: false,
            child: loading && profile == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHero(context, facility),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSummary(
                              facility,
                              averageRating,
                              reviewCount,
                            ),
                            const SizedBox(height: 16),
                            _buildDescription(facility),
                            const SizedBox(height: 16),
                            _buildSports(facility),
                            const SizedBox(height: 16),
                            _buildAmenities(facility),
                            const SizedBox(height: 16),
                            _buildAccessibility(facility),
                            const SizedBox(height: 18),
                            _buildDetailsLink(facility),
                            const SizedBox(height: 18),
                            if (profile?.reviewsError != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Could not load reviews: ${profile!.reviewsError}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            _buildReviews(
                              reviews,
                              reviewCount,
                              error: profile?.reviewsError,
                            ),
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
                  onPressed: loading
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SlotSelectionScreen(
                              courtName: _displayName(facility),
                            ),
                          ),
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
      },
    );
  }

  Widget _buildHero(BuildContext context, Map<String, dynamic>? facility) {
    final photos = _facilityPhotos(facility);
    final photoUrl = photos.isEmpty
        ? ''
        : photos[_selectedPhotoIndex.clamp(0, photos.length - 1).toInt()];

    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onHorizontalDragEnd: photos.length < 2
                ? null
                : (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity.abs() < 80) return;
                    setState(() {
                      _selectedPhotoIndex = velocity < 0
                          ? (_selectedPhotoIndex + 1) % photos.length
                          : (_selectedPhotoIndex - 1 + photos.length) %
                                photos.length;
                    });
                  },
            child: _buildHeroImage(photoUrl),
          ),
          if (photos.length > 1) ...[
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedPhotoIndex + 1}/${photos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ],
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
                _roundAction(
                  icon: Icons.share_outlined,
                  onTap: () => _shareFacility(facility),
                ),
                const SizedBox(width: 10),
                _roundAction(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onTap: () => _toggleFavorite(facility),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _facilityPhotos(Map<String, dynamic>? facility) {
    final photos = facility?['photos'];
    final urls = photos is List
        ? photos
              .map((photo) => photo.toString().trim())
              .where((photo) => photo.startsWith('http://') || photo.startsWith('https://'))
              .take(5)
              .toList()
        : <String>[];
    if (urls.isNotEmpty) return urls;
    final photoUrl = facility?['photoUrl']?.toString().trim() ?? '';
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return [photoUrl];
    }
    return [];
  }

  Widget _buildHeroImage(String photoUrl) {
    if (photoUrl.isNotEmpty &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _heroPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: widget.color,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            ),
          );
        },
      );
    }
    if (widget.imagePath != null) {
      return Image.asset(widget.imagePath!, fit: BoxFit.cover);
    }
    return _heroPlaceholder();
  }

  Widget _heroPlaceholder() {
    return Container(
      color: widget.color,
      child: Icon(widget.icon, color: Colors.white70, size: 82),
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

  Widget _buildSummary(
    Map<String, dynamic>? facility,
    double averageRating,
    int reviewCount,
  ) {
    final location =
        facility?['location']?.toString().trim().isNotEmpty == true
        ? facility!['location'].toString()
        : widget.distance;
    final contact =
        facility?['contactNumber']?.toString().trim().isNotEmpty == true
        ? facility!['contactNumber'].toString()
        : 'Contact unavailable';
    final openTime = facility?['openTime']?.toString().trim().isNotEmpty == true
        ? facility!['openTime'].toString()
        : 'Hours unavailable';
    final displayName = _displayName(facility);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewScreen(facilityName: displayName),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFF4A340), size: 15),
              const SizedBox(width: 4),
              Text(
                _ratingSummary(averageRating, reviewCount),
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
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _infoTile(Icons.phone_outlined, 'Contact', contact),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoTile(Icons.access_time, 'Open hours', openTime),
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
          Expanded(
            child: Column(
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Map<String, dynamic>? facility) {
    final description = facility?['description']?.toString().trim();
    return Text(
      description?.isNotEmpty == true
          ? description!
          : 'Facility details will appear here once they are added by the venue manager.',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        height: 1.45,
      ),
    );
  }

  Widget _buildSports(Map<String, dynamic>? facility) {
    final sports = _stringList(facility?['availableSports']);
    if (sports.isEmpty) {
      sports.add(_displaySport(facility));
    }
    return _section(
      'Sports available',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: sports.map(_tag).toList(),
      ),
    );
  }

  Widget _buildAmenities(Map<String, dynamic>? facility) {
    final amenities = _stringList(facility?['amenities']);
    if (amenities.isEmpty) {
      return _section(
        'Amenities',
        const Text(
          'No amenities listed yet.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      );
    }
    return _section(
      'Amenities',
      Wrap(
        runSpacing: 11,
        spacing: 8,
        children: amenities
            .map(
              (item) => _FeatureItem(Icons.check_circle_outline, item),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAccessibility(Map<String, dynamic>? facility) {
    final items = _stringList(facility?['accessibility']);
    if (items.isEmpty) {
      return _section(
        'Accessibility',
        const Text(
          'No accessibility information listed yet.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      );
    }
    return _section(
      'Accessibility',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _FeatureItem(Icons.accessible_forward, items[i]),
          ],
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

  Widget _buildDetailsLink(Map<String, dynamic>? facility) {
    final centre = facility?['centreName']?.toString();
    final surface = facility?['surface']?.toString();
    final subtitle = [
      if (centre != null && centre.isNotEmpty) centre,
      if (surface != null && surface.isNotEmpty) surface,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subtitle.isNotEmpty
                  ? subtitle
                  : 'Full contact & accessibility details',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 17),
        ],
      ),
    );
  }

  Widget _buildReviews(
    List<Review> reviews,
    int reviewCount, {
    String? error,
  }) {
    final displayName = widget.name;

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
                  builder: (_) => ReviewScreen(facilityName: displayName),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: Text(
                  'See all ($reviewCount)',
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
        if (error != null)
          _reviewContainer(
            const Text(
              'Reviews are temporarily unavailable.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          )
        else if (reviews.isEmpty)
          _reviewContainer(
            const Text(
              'No reviews yet. Be the first player to share your experience.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          )
        else
          ...reviews.take(3).map(_reviewCard),
      ],
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
