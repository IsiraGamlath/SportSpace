import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'facility_profile_screen.dart';
import 'account_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _sport;
  String? _location;
  String? _price;
  bool _showFavoritesOnly = false;
  Set<String> _favoriteNames = {};
  late Future<List<Facility>> _facilitiesFuture;

  @override
  void initState() {
    super.initState();
    _facilitiesFuture = ApiService.fetchFacilities();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.loadFavorites();
    if (mounted) setState(() => _favoriteNames = favorites);
  }

  Future<void> _toggleFavorite(String facilityName) async {
    final isFavorite = await FavoritesService.toggleFavorite(facilityName);
    if (!mounted) return;
    setState(() {
      if (isFavorite) {
        _favoriteNames.add(facilityName);
      } else {
        _favoriteNames.remove(facilityName);
      }
    });
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    return FutureBuilder<List<Facility>>(
      future: _facilitiesFuture,
      builder: (context, snapshot) {
        final facilities = (snapshot.data ?? []).where((facility) {
          final searchable = '${facility.name} ${facility.sport} Colombo'
              .toLowerCase();
          return (_sport == null || facility.sport == _sport) &&
              (_location == null || _location == 'Colombo') &&
              _matchesPrice(facility.price) &&
              (!_showFavoritesOnly || _favoriteNames.contains(facility.name)) &&
              (query.isEmpty || searchable.contains(query));
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(
                        side: BorderSide(color: AppColors.borderLight),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textPrimary,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Explore Facilities',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSearchField(),
                const SizedBox(height: 10),
                _buildFilterChips(),
                const SizedBox(height: 14),
                Text(
                  '${facilities.length} facilities found near Colombo',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'Unable to load facilities: ${snapshot.error}',
                      ),
                    ),
                  )
                else if (facilities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        _showFavoritesOnly
                            ? 'No favourite facilities yet. Tap a heart to save one.'
                            : 'No facilities found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...facilities.map(
                    (facility) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FacilityCard(
                        facility: _ExploreFacility.fromFacility(facility),
                        isFavorite: _favoriteNames.contains(facility.name),
                        onFavoriteTap: () => _toggleFavorite(facility.name),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FacilityProfileScreen(
                                name: facility.name,
                                sport: facility.sport,
                                distance: 'Colombo',
                                rating: '—',
                                price: facility.price,
                                color: _ExploreFacility._sportColor(
                                  facility.sport,
                                ),
                                icon: _ExploreFacility._sportIcon(facility.sport),
                                imagePath: null,
                              ),
                            ),
                          );
                          await _loadFavorites();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 1,
            onItemSelected: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                );
              } else if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              }
            },
          ),
        );
      },
    );
  }

  bool _matchesPrice(int price) {
    if (_price == null) return true;
    if (_price == 'Under Rs. 1,500') return price < 1500;
    if (_price == 'Rs. 1,500 - 2,000') return price >= 1500 && price <= 2000;
    return price > 2000;
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search facilities',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryTeal),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Filters',
            icon: Icons.tune,
            selected: _sport != null ||
                _location != null ||
                _price != null ||
                _showFavoritesOnly,
            onTap: _showAllFilters,
          ),
          _FilterChip(
            label: 'Favourites',
            selected: _showFavoritesOnly,
            onTap: () => setState(
              () => _showFavoritesOnly = !_showFavoritesOnly,
            ),
          ),
          _FilterChip(
            label: _sport ?? 'Sport',
            selected: _sport != null,
            onTap: () => _showOptions(
              'Sport',
              [
                'Cricket',
                'Badminton',
                'Football',
                'Basketball',
                'Tennis',
                'Swimming',
              ],
              _sport,
              (value) => setState(() => _sport = value),
            ),
          ),
          _FilterChip(
            label: _location ?? 'Location',
            selected: _location != null,
            onTap: () => _showOptions(
              'Location',
              ['Colombo'],
              _location,
              (value) => setState(() => _location = value),
            ),
          ),
          _FilterChip(
            label: _price ?? 'Price',
            selected: _price != null,
            onTap: () => _showOptions(
              'Price',
              ['Under Rs. 1,500', 'Rs. 1,500 - 2,000', 'Above Rs. 2,000'],
              _price,
              (value) => setState(() => _price = value),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOptions(
    String title,
    List<String> options,
    String? selected,
    ValueChanged<String?> onSelected,
  ) async {
    final value = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) =>
          _OptionsSheet(title: title, options: options, selected: selected),
    );
    if (value == null && selected == null) return;
    onSelected(value);
  }

  Future<void> _showAllFilters() async {
    final clear = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.clear_all),
          title: const Text('Clear all filters'),
          onTap: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (clear == true) {
      setState(() {
        _sport = null;
        _location = null;
        _price = null;
        _showFavoritesOnly = false;
      });
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.darkNavy : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.darkNavy : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: selected ? Colors.white : AppColors.darkNavy,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ListTile(
              title: const Text('All'),
              trailing: selected == null
                  ? const Icon(Icons.check, color: AppColors.primaryTeal)
                  : null,
              onTap: () => Navigator.pop(context, null),
            ),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                trailing: selected == option
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.facility,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  final _ExploreFacility facility;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  Widget _facilityImageFallback(_ExploreFacility facility) {
    return Container(
      color: facility.color,
      child: Center(
        child: Icon(facility.icon, color: Colors.white70, size: 58),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 126,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (facility.imageUrl != null)
                    Image.network(
                      facility.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _facilityImageFallback(facility),
                    )
                  else if (facility.imagePath == null)
                    _facilityImageFallback(facility)
                  else
                    Image.asset(facility.imagePath!, fit: BoxFit.cover),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.92),
                      child: IconButton(
                        onPressed: onFavoriteTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 28,
                          height: 28,
                        ),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                          color: isFavorite
                              ? Colors.redAccent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF4A340),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        facility.rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${facility.sport}   •   ${facility.distance}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Rs. ${facility.price}/hr',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.availableBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '● Available today',
                          style: TextStyle(
                            color: AppColors.available,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
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
}

class _ExploreFacility {
  factory _ExploreFacility.fromFacility(Facility facility) {
    return _ExploreFacility(
      facility.name,
      facility.sport,
      'Colombo',
      '—',
      facility.price,
      _sportColor(facility.sport),
      _sportIcon(facility.sport),
      imageUrl: facility.photoUrl,
    );
  }

  const _ExploreFacility(
    this.name,
    this.sport,
    this.distance,
    this.rating,
    this.price,
    this.color,
    this.icon, {
    this.imagePath,
    this.imageUrl,
  });

  final String name;
  final String sport;
  final String distance;
  final String rating;
  final int price;
  final Color color;
  final IconData icon;
  final String? imagePath;
  final String? imageUrl;

  static Color _sportColor(String sport) =>
      const {
        'Badminton': Color(0xFF477D82),
        'Tennis': Color(0xFFB77B64),
        'Basketball': Color(0xFFC9A878),
        'Football': Color(0xFF5E8C61),
      }[sport] ??
      const Color(0xFF55718D);

  static IconData _sportIcon(String sport) =>
      const {
        'Badminton': Icons.sports_tennis,
        'Tennis': Icons.sports_tennis,
        'Basketball': Icons.sports_basketball,
        'Football': Icons.sports_soccer,
        'Swimming': Icons.pool,
        'Cricket': Icons.sports_cricket,
      }[sport] ??
      Icons.sports;
}
