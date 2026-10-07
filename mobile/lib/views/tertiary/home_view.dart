

import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/category_quick_select.dart';
import '../../widgets/tertiary/nearby_event_card.dart';
import 'placeholder_view.dart';
import 'events_view.dart';
import 'event_details_view.dart';

class TertiaryHomeView extends StatefulWidget {
  const TertiaryHomeView({super.key});

  @override
  State<TertiaryHomeView> createState() => _TertiaryHomeViewState();
}

class _TertiaryHomeViewState extends State<TertiaryHomeView> {
  // Home corresponds to index 0 in TertiaryNavBar
  // (Home, Events, Facilities, Notifications, Profile).
  int _currentIndex = 0;

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

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await appServices.eventRepository.getEvents();
    if (!mounted) return;
    setState(() {
      _nearbyEvents = events.take(2).toList();
      _isLoading = false;
    });
  }

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;
    const labels = ['Home', 'Events', 'Facilities', 'Notifications', 'Profile'];

    if (index == 1) {
      // Events screen now exists — push it directly instead of a
      // placeholder. EventsView's own nav bar pops back to Home when
      // the Home tab is tapped from there.
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EventsView()),
      );
      return;
    }

    setState(() => _currentIndex = index);

    // Facilities/Notifications/Profile don't exist yet, so tapping
    // their tab opens a lightweight placeholder instead.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => TertiaryPlaceholderView(title: labels[index]),
      ),
    )
        .then((_) {
      if (mounted) setState(() => _currentIndex = 0);
    });
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = _nearbyEvents[index];
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
                        childCount: _nearbyEvents.length,
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
          const SizedBox(width: 12),
          const CircleAvatar(
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventsView()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, size: 20, color: Color(0xFF9AA4B2)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search facilities, sports or locations',
                  style: TextStyle(fontSize: 13.5, color: _subtext),
                ),
              ),
            ],
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
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryQuickSelect(
                icon: category.icon,
                label: category.label,
                onTap: () {},
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