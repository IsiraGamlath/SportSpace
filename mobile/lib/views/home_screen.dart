import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'explore_screen.dart';
import 'facility_profile_screen.dart';
import 'my_bookings_screen.dart';
import 'tertiary/profile_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;
  late Future<List<Facility>> _facilitiesFuture;

  static const _events = [
    _EventData(
      'Colombo Weekend 5K Run',
      'Sat, 12 Oct  •  6:30 AM',
      'Viharamahadevi Park',
      Color(0xFF4C7895),
      Icons.directions_run,
    ),
    _EventData(
      'Community Badminton Meetup',
      'Sun, 20 Oct  •  4:00 PM',
      'City Sports Complex',
      Color(0xFF8B6E54),
      Icons.sports_tennis,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _facilitiesFuture = ApiService.fetchFacilities();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _userName() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  String _greetingName(String userName) {
    return userName.trim().split(RegExp(r'\s+')).first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userName();
    final greetingName = _greetingName(userName);
    final query = _searchController.text.trim().toLowerCase();

    return FutureBuilder<List<Facility>>(
      future: _facilitiesFuture,
      builder: (context, snapshot) {
        final facilities = (snapshot.data ?? [])
            .where((facility) {
              final matchesSport =
                  _selectedSport == null || facility.sport == _selectedSport;
              final searchable = '${facility.name} ${facility.sport}'
                  .toLowerCase();
              return matchesSport &&
                  (query.isEmpty || searchable.contains(query));
            })
            .take(8)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(userName, greetingName),
                  const SizedBox(height: 18),
                  _buildSearchField(),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Popular Sports'),
                  const SizedBox(height: 10),
                  _buildSports(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Nearby & Recommended', showViewAll: true),
                  const SizedBox(height: 10),
                  if (facilities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No facilities found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...facilities.expand(
                      (facility) => [
                        _FacilityCard.fromFacility(
                          facility,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FacilityProfileScreen(
                                name: facility.name,
                                sport: facility.sport,
                                distance: 'Colombo',
                                rating: '—',
                                price: facility.price,
                                color: _sportColor(facility.sport),
                                icon: _sportIcon(facility.sport),
                                imagePath: facility.photoUrl,
                              ),
                            ),
                          ),
                        ),
                        if (facility != facilities.last)
                          const SizedBox(height: 12),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Community Events', showViewAll: true),
                  const SizedBox(height: 10),
                  ..._events.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CommunityEventCard(event: event),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: 0,
            onItemSelected: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ExploreScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const MyBookingsScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              } else if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ProfileView(role: 'Player'),
                    transitionDuration: Duration.zero,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Color _sportColor(String sport) =>
      const {
        'Badminton': Color(0xFF477D82),
        'Tennis': Color(0xFFB77B64),
        'Basketball': Color(0xFFC9A878),
        'Football': Color(0xFF5E8C61),
      }[sport] ??
      const Color(0xFF55718D);

  IconData _sportIcon(String sport) =>
      const {
        'Badminton': Icons.sports_tennis,
        'Tennis': Icons.sports_tennis,
        'Basketball': Icons.sports_basketball,
        'Football': Icons.sports_soccer,
        'Swimming': Icons.pool,
        'Cricket': Icons.sports_cricket,
      }[sport] ??
      Icons.sports;

  Widget _buildHeader(String userName, String greetingName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, $greetingName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Ready to play?',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.darkNavy,
            shape: BoxShape.circle,
          ),
          child: Text(
            _initials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length > 1) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search facilities, sports or locations',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (showViewAll)
          const Text(
            'View All',
            style: TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildSports() {
    const sports = [
      (Icons.sports_cricket, 'Cricket'),
      (Icons.sports_tennis, 'Badminton'),
      (Icons.sports_soccer, 'Football'),
      (Icons.sports_basketball, 'Basketball'),
      (Icons.sports_tennis, 'Tennis'),
      (Icons.pool, 'Swimming'),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sports.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final sport = sports[index];
          return SizedBox(
            width: 54,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(
                    () => _selectedSport = _selectedSport == sport.$2
                        ? null
                        : sport.$2,
                  ),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _selectedSport == sport.$2
                          ? AppColors.primaryTeal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Icon(
                      sport.$1,
                      color: _selectedSport == sport.$2
                          ? Colors.white
                          : AppColors.darkNavy,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sport.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  _FacilityCard.fromFacility(Facility facility, {required VoidCallback onTap})
    : this(
        name: facility.name,
        sport: facility.sport,
        distance: 'Colombo',
        color: _facilityColor(facility.sport),
        icon: _facilityIcon(facility.sport),
        rating: '—',
        imagePath: facility.photoUrl,
        onTap: onTap,
      );

  _FacilityCard.fromData(_FacilityData data, {required VoidCallback onTap})
    : this(
        name: data.name,
        sport: data.sport,
        distance: data.distance,
        color: data.color,
        icon: data.icon,
        rating: data.rating,
        imagePath: data.imagePath,
        onTap: onTap,
      );

  const _FacilityCard({
    required this.name,
    required this.sport,
    required this.distance,
    required this.color,
    required this.icon,
    required this.rating,
    required this.imagePath,
    required this.onTap,
  });

  final String name;
  final String sport;
  final String distance;
  final Color color;
  final IconData icon;
  final String rating;
  final String? imagePath;
  final VoidCallback onTap;

  static Color _facilityColor(String sport) =>
      const {
        'Badminton': Color(0xFF477D82),
        'Tennis': Color(0xFFB77B64),
        'Basketball': Color(0xFFC9A878),
        'Football': Color(0xFF5E8C61),
      }[sport] ??
      const Color(0xFF55718D);

  static IconData _facilityIcon(String sport) =>
      const {
        'Badminton': Icons.sports_tennis,
        'Tennis': Icons.sports_tennis,
        'Basketball': Icons.sports_basketball,
        'Football': Icons.sports_soccer,
        'Swimming': Icons.pool,
        'Cricket': Icons.sports_cricket,
      }[sport] ??
      Icons.sports;

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
              height: 108,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.55)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: imagePath == null
                        ? Center(
                            child: Icon(
                              icon,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 54,
                            ),
                          )
                        : Image.network(
                            imagePath!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                icon,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 54,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$sport   •   Colombo   •   $distance',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF4A340),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
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
                            fontSize: 10,
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

class _FacilityData {
  const _FacilityData(
    this.name,
    this.sport,
    this.distance,
    this.color,
    this.icon,
    this.rating, {
    this.imagePath,
  });

  final String name;
  final String sport;
  final String distance;
  final Color color;
  final IconData icon;
  final String rating;
  final String? imagePath;
}

class _EventData {
  const _EventData(this.title, this.date, this.location, this.color, this.icon);

  final String title;
  final String date;
  final String location;
  final Color color;
  final IconData icon;
}

class _CommunityEventCard extends StatelessWidget {
  const _CommunityEventCard({required this.event});

  final _EventData event;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            height: 108,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        event.color,
                        event.color.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      event.icon,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 54,
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: const Icon(
                      Icons.event_available,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.date,
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        event.location,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.availableBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Join event',
                    style: TextStyle(
                      color: AppColors.available,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
