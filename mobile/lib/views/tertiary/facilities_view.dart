import 'package:flutter/material.dart';

import '../../models/facility_info_model.dart';
import '../../utils/tertiary_navigation.dart';
import '../../widgets/tertiary/event_image.dart';
import '../../widgets/tertiary/filter_chip.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../services/api_service.dart';
import 'facility_details_view.dart';
import 'notifications_view.dart';

class FacilitiesView extends StatefulWidget {
  const FacilitiesView({super.key});

  @override
  State<FacilitiesView> createState() => _FacilitiesViewState();
}

class _FacilitiesViewState extends State<FacilitiesView> {
  // Facilities corresponds to index 2 in TertiaryNavBar.
  static const int _tabIndex = 2;

  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF1D7A6B);
  static const Color _cardBorder = Color(0xFFE7EAF0);
  static const Color _statusBg = Color(0xFFE5F7EC);
  static const Color _statusDot = Color(0xFF2E8B57);
  static const Color _statusText = Color(0xFF1C7A4C);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSport = 'All';

  final List<String> _sportFilters = const [
    'All',
    'Badminton',
    'Football',
    'Basketball',
    'Tennis',
    'Swimming',
  ];

  List<FacilityItem> _facilities = List.from(kMockFacilities);

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final backendList = await ApiService.fetchManagerFacilities();
      if (backendList.isNotEmpty && mounted) {
        setState(() {
          _facilities =
              backendList.map((e) => FacilityItem.fromBackendJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FacilityItem> get _filteredFacilities {
    final query = _searchQuery.trim().toLowerCase();

    return _facilities.where((facility) {
      final matchesSearch = query.isEmpty ||
          facility.name.toLowerCase().contains(query) ||
          facility.cityLocation.toLowerCase().contains(query) ||
          facility.address.toLowerCase().contains(query) ||
          facility.availableSports
              .any((s) => s.toLowerCase().contains(query));

      final matchesSport = _selectedSport == 'All' ||
          facility.availableSports.any(
            (s) => s.toLowerCase() == _selectedSport.toLowerCase(),
          );

      return matchesSearch && matchesSport;
    }).toList();
  }

  void _openFacilityDetails(FacilityItem facility) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilityDetailsView(
          title: facility.name,
          imageUrl: facility.imageUrl,
          status: facility.status,
          cityLocation: facility.cityLocation,
          scheduleTimeRange: facility.scheduleTimeRange,
          scheduleEventTitle: facility.scheduleEventTitle,
          openingHours: facility.openingHours,
          availableSports: facility.availableSports,
          amenities: facility.amenities,
          upcomingEvents: facility.upcomingEvents,
          accessibilityNote: facility.accessibilityNote,
          facilityId: facility.id,
          facilityName: facility.name,
          phone: facility.phone,
          email: facility.email,
          address: facility.address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facilities = _filteredFacilities;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Facilities & Venues (${facilities.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _heading,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty || _selectedSport != 'All')
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedSport = 'All';
                            _searchController.clear();
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (facilities.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final facility = facilities[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFacilityCard(facility),
                      );
                    },
                    childCount: facilities.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: TertiaryNavBar(
        currentIndex: _tabIndex,
        onItemSelected: (index) => handleTertiaryNavTap(
          context: context,
          tappedIndex: index,
          currentIndex: _tabIndex,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canPop) ...[
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: _heading,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
              ],
              const Text(
                'Facilities',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsView()),
            ),
            borderRadius: BorderRadius.circular(19),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _cardBorder),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 19,
                color: _heading,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: Color(0xFF9AA4B2),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFF9AA4B2),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            hintText: 'Search facilities, sports or locations',
            hintStyle: const TextStyle(fontSize: 13.5, color: _subtext),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sportFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _sportFilters[index];
          final isSelected = _selectedSport == filter;
          return EventFilterChip(
            label: filter,
            isActive: isSelected,
            onTap: () => setState(() => _selectedSport = filter),
          );
        },
      ),
    );
  }

  Widget _buildFacilityCard(FacilityItem facility) {
    return InkWell(
      onTap: () => _openFacilityDetails(facility),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
                  child: EventImage(imageUrl: facility.imageUrl),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          facility.status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${facility.rating} · ${facility.distance}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _heading,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: _accent,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          facility.cityLocation,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _subtext,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: _subtext,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        facility.openingHours,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _subtext,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: facility.availableSports.map((sport) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sport,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _heading,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.domain_disabled_rounded,
            size: 44,
            color: Color(0xFFC3C9D3),
          ),
          const SizedBox(height: 12),
          const Text(
            'No facilities found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _heading,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try searching a different name, location, or sport.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _subtext),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedSport = 'All';
                _searchController.clear();
              });
            },
            child: const Text('Reset search & filters'),
          ),
        ],
      ),
    );
  }
}
