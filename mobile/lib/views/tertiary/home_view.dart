

import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import '../../utils/tertiary_navigation.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/category_quick_select.dart';
import '../../widgets/tertiary/nearby_event_card.dart';
<<<<<<< Updated upstream
import 'events_view.dart';
import 'event_details_view.dart';
import 'my_requests_view.dart';
import 'profile_view.dart';
=======
import 'placeholder_view.dart';
import '../account_profile_screen.dart';
>>>>>>> Stashed changes

class TertiaryHomeView extends StatefulWidget {
  const TertiaryHomeView({super.key});

  @override
  State<TertiaryHomeView> createState() => _TertiaryHomeViewState();
}

class _TertiaryHomeViewState extends State<TertiaryHomeView> {
  // Home corresponds to index 0 in TertiaryNavBar
  // (Home, Events, Facilities, Notifications, Profile).
  final int _currentIndex = 0;

  // Local constants — replace with your app theme if available.
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _accent = Color(0xFF2E8B57);

  final List<_CategoryItem> _categories = const [
    _CategoryItem(icon: Icons.sports_handball, label: 'Badminton'),
    _CategoryItem(icon: Icons.sports_soccer, label: 'Football'),
    _CategoryItem(icon: Icons.sports_basketball, label: 'Basketball'),
    _CategoryItem(icon: Icons.sports_tennis, label: 'Tennis'),
    _CategoryItem(icon: Icons.pool, label: 'Swim'),
  ];

  bool _isLoading = true;
  List<NearbyEvent> _nearbyEvents = [];
  List<NearbyEvent> _allEvents = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final events = await appServices.eventRepository.getEvents();
    if (!mounted) return;
    setState(() {
      _allEvents = events;
      _nearbyEvents = events.take(2).toList();
      _isLoading = false;
    });
  }

  List<NearbyEvent> get _displayedNearbyEvents {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _nearbyEvents;
    }
    return _allEvents.where((e) {
      return e.title.toLowerCase().contains(query) ||
          e.sport.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query) ||
          e.facility.toLowerCase().contains(query);
    }).toList();
  }

  void _onNavItemSelected(int index) {
<<<<<<< Updated upstream
    handleTertiaryNavTap(
      context: context,
      tappedIndex: index,
      currentIndex: _currentIndex,
    );
=======
    if (index == _currentIndex) return;

    const labels = ['Home', 'Events', 'Facilities', 'Notifications', 'Profile'];

    setState(() => _currentIndex = index);

    final destination = index == 4
        ? const UserProfileScreen(communityMode: true)
        : TertiaryPlaceholderView(title: labels[index]);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => destination,
      ),
    )
        .then((_) {
      if (mounted) setState(() => _currentIndex = 0);
    });
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildPopularEvents()),
                  SliverToBoxAdapter(child: _buildNearbyHeader()),
                  if (_displayedNearbyEvents.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE7EAF0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded,
                                  size: 34, color: Color(0xFF9AA4B2)),
                              const SizedBox(height: 8),
                              Text(
                                'No events match "$_searchQuery"',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _heading,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try another sport, location or view full schedules.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: _subtext),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventsView(initialQuery: _searchQuery),
                                    ),
                                  );
                                },
                                child: const Text(
                                    'Search in all Events & Schedules →'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = _displayedNearbyEvents[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: NearbyEventCard(
                                event: event,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsView(event: event),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _displayedNearbyEvents.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      // --- Reused global nav bar, not re-implemented here -----------------
      bottomNavigationBar: TertiaryNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Good morning, Saantha',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: _heading,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('👋', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ready to play?',
                  style: TextStyle(fontSize: 13.5, color: _subtext),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyRequestsView()),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7EAF0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined, size: 15, color: _heading),
                  SizedBox(width: 4),
                  Text(
                    'My Requests',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileView()),
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: _heading,
              child: Text(
                'SS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          onSubmitted: (value) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventsView(initialQuery: value),
              ),
            );
          },
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon:
                const Icon(Icons.search, size: 20, color: Color(0xFF9AA4B2)),
            suffixIcon: _searchQuery.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Color(0xFF9AA4B2)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                      IconButton(
                        tooltip: 'View in Events',
                        icon: const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: _accent),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EventsView(initialQuery: _searchQuery),
                            ),
                          );
                        },
                      ),
                    ],
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

  Widget _buildPopularEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            'Popular Events',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _heading,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryQuickSelect(
                icon: category.icon,
                label: category.label,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EventsView(initialQuery: category.label),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNearbyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Nearby & Recommended',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _heading,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EventsView()),
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});
}
