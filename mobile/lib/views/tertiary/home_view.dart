// lib/views/tertiary/home_view.dart
//
// Tertiary Stakeholder (Viewer / Public User) Home screen.
//
// Accurately matching the prototype UI layout:
// - Header with user greeting, emoji, and avatar initials ("SS")
// - Rounded search bar
// - Popular Events horizontal quick select cards
// - Nearby & Recommended section with View All
// - Rich event cards with title, status pill badge, date/time, and venue location
// - Bottom Navigation Bar with Home, Events, Facilities, Notifications, Profile

import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/category_quick_select.dart';
import '../../widgets/tertiary/nearby_event_card.dart';
import 'placeholder_view.dart';

class TertiaryHomeView extends StatefulWidget {
  const TertiaryHomeView({super.key});

  @override
  State<TertiaryHomeView> createState() => _TertiaryHomeViewState();
}

class _TertiaryHomeViewState extends State<TertiaryHomeView> {
  int _currentIndex = 0;
  String _selectedCategory = 'Badminton';

  // Palette matching the prototype
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _heading = Color(0xFF0F2641);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _viewAllBlue = Color(0xFF1E75D8);
  static const Color _avatarBg = Color(0xFF0E4C75);

  // Categories matching the prototype icons & labels
  final List<_CategoryItem> _categories = const [
    _CategoryItem(
      icon: Icons.grid_view_rounded,
      label: 'Badminton',
    ),
    _CategoryItem(
      icon: Icons.explore_outlined,
      label: 'Football',
    ),
    _CategoryItem(
      icon: Icons.star_rounded,
      label: 'Basketball',
    ),
    _CategoryItem(
      icon: Icons.calendar_today_outlined,
      label: 'Tennis',
    ),
    _CategoryItem(
      icon: Icons.access_time_rounded,
      label: 'Swimming',
    ),
  ];

  // Events matching the prototype cards
  final List<NearbyEvent> _nearbyEvents = const [
    NearbyEvent(
      title: 'Colombo Community\nBadminton Open',
      sport: 'Badminton',
      date: '20 Sep 2026',
      time: '9:00 AM–5:00 PM',
      location: 'Colombo Sports Hub',
      status: 'Open',
      imageUrl: 'assets/images/badminton.jpg',
    ),
    NearbyEvent(
      title: 'Youth Football Training\nDay',
      sport: 'Football',
      date: '22 Sep 2026',
      time: '4:00 PM–7:00 PM',
      location: 'City Sports Ground',
      status: 'Confirmed',
      imageUrl: 'assets/images/football.jpg',
    ),
  ];

  void _onNavItemSelected(int index) {
    if (index == _currentIndex) return;

    const labels = ['Home', 'Events', 'Facilities', 'Notifications', 'Profile'];

    setState(() => _currentIndex = index);

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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildPopularEvents()),
            SliverToBoxAdapter(child: _buildNearbyHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = _nearbyEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: NearbyEventCard(
                        event: event,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TertiaryPlaceholderView(
                              title: event.title.replaceAll('\n', ' '),
                            ),
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
      bottomNavigationBar: TertiaryNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Good morning, Saantha',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _heading,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 19),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Ready to play?',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _subtext,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _avatarBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'SS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 21, color: Color(0xFF8A93A3)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search facilities, sports or locations',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF8A93A3),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
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
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _heading,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return CategoryQuickSelect(
                icon: category.icon,
                label: category.label,
                isSelected: _selectedCategory == category.label,
                onTap: () {
                  setState(() {
                    _selectedCategory = category.label;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildNearbyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Nearby & Recommended',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _heading,
              letterSpacing: -0.2,
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _viewAllBlue,
                ),
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