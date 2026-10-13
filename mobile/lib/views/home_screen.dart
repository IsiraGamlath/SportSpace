import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../models/sport_event_model.dart';
import '../services/api_service.dart';
import '../services/event_repository.dart';
import '../services/favorites_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'explore_screen.dart';
import 'facility_profile_screen.dart';
import 'my_bookings_screen.dart';
import 'player_notifications_view.dart';
import 'account_profile_screen.dart';
import '../services/app_services.dart';
import 'player_main_screen.dart';
import 'tertiary/event_details_view.dart';
import 'tertiary/events_view.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;
  const HomeScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final EventRepository _eventRepository = appServices.eventRepository;
  String? _selectedSport;
  Set<String> _favoriteNames = {};
  late Future<List<Facility>> _facilitiesFuture;
  late Future<List<NearbyEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _facilitiesFuture = ApiService.fetchFacilities();
    _eventsFuture = _eventRepository.getEvents();
    if (_eventRepository is ChangeNotifier) {
      (_eventRepository as ChangeNotifier).addListener(_onEventsChanged);
    }
    _loadFavorites();
  }

  void _onEventsChanged() {
    if (mounted) {
      setState(() {
        _eventsFuture = Future.value(_eventRepository.currentEvents);
      });
    }
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _userName() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final displayName = user?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) return displayName;

      final email = user?.email;
      if (email != null && email.contains('@')) return email.split('@').first;
    } catch (_) {}
    return 'there';
  }

  String _greetingName(String userName) {
    return userName.trim().split(RegExp(r'\s+')).first;
  }

  @override
  void dispose() {
    if (_eventRepository is ChangeNotifier) {
      (_eventRepository as ChangeNotifier).removeListener(_onEventsChanged);
    }
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
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _facilitiesFuture = ApiService.fetchFacilities();
                  _eventsFuture = _eventRepository.getEvents(forceRefresh: true);
                });
                await Future.wait([_facilitiesFuture, _eventsFuture]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                  color: _sportColor(facility.sport),
                                  icon: _sportIcon(facility.sport),
                                ),
                              ),
                            );
                            await _loadFavorites();
                          },
                        ),
                        if (facility != facilities.last)
                          const SizedBox(height: 12),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Community Events',
                    showViewAll: true,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const EventsView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<NearbyEvent>>(
                    future: _eventsFuture,
                    builder: (context, eventSnapshot) {
                      if (eventSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !eventSnapshot.hasData &&
                          _eventRepository.currentEvents.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final allEvents = eventSnapshot.data ??
                          _eventRepository.currentEvents;
                      final liveEvents = allEvents.where((event) {
                        final matchesSport = _selectedSport == null ||
                            event.sport.toLowerCase() ==
                                _selectedSport!.toLowerCase();
                        final searchable =
                            '${event.title} ${event.sport} ${event.location} ${event.facility}'
                                .toLowerCase();
                        return matchesSport &&
                            (query.isEmpty || searchable.contains(query));
                      }).toList();

                      if (liveEvents.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No community events found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: liveEvents.take(4).map((event) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CommunityEventCard(
                              event: event,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => EventDetailsView(event: event),
                                  ),
                                );
                                if (mounted) {
                                  setState(() {
                                    _eventsFuture = _eventRepository.getEvents();
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
          bottomNavigationBar: widget.showBottomNav
              ? AppBottomNav(
                  currentIndex: 0,
                  onItemSelected: (index) {
                    final parent = PlayerMainScreen.of(context);
                    if (parent != null) {
                      parent.setTab(index);
                      return;
                    }
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
                          pageBuilder: (_, __, ___) => const UserProfileScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    } else if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlayerNotificationsView(),
                        ),
                      );
                    }
                  },
                )
              : null,
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
        ListenableBuilder(
          listenable: appServices.notificationService,
          builder: (context, _) {
            final count =
                appServices.notificationService.unreadCountForRole('player');
            return Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  key: const Key('home_notification_bell'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerNotificationsView(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      key: const Key('home_notification_badge'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE14C4C),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 10),
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

  Widget _buildSectionTitle(
    String title, {
    bool showViewAll = false,
    VoidCallback? onViewAll,
  }) {
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
          TextButton(
            onPressed: onViewAll ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ExploreScreen(),
                    ),
                  );
                },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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
  _FacilityCard.fromFacility(
    Facility facility, {
    required VoidCallback onTap,
    required bool isFavorite,
    required VoidCallback onFavoriteTap,
  }) : this(
         name: facility.name,
         sport: facility.sport,
         distance: 'Colombo',
         color: _facilityColor(facility.sport),
         icon: _facilityIcon(facility.sport),
         rate: 'Rs. ${facility.price}/hr',
         imageUrl: facility.photoUrl,
         imagePath: null,
         isFavorite: isFavorite,
         onFavoriteTap: onFavoriteTap,
         onTap: onTap,
       );

  _FacilityCard.fromData(_FacilityData data, {required VoidCallback onTap})
    : this(
        name: data.name,
        sport: data.sport,
        distance: data.distance,
        color: data.color,
        icon: data.icon,
        rate: data.rating,
        imagePath: data.imagePath,
        isFavorite: false,
        onTap: onTap,
      );

  const _FacilityCard({
    required this.name,
    required this.sport,
    required this.distance,
    required this.color,
    required this.icon,
    required this.rate,
    this.imageUrl,
    required this.imagePath,
    this.isFavorite = false,
    this.onFavoriteTap,
    required this.onTap,
  });

  final String name;
  final String sport;
  final String distance;
  final Color color;
  final IconData icon;
  final String rate;
  final String? imageUrl;
  final String? imagePath;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
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
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                icon,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 54,
                              ),
                            ),
                          )
                        : imagePath == null
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
                      child: IconButton(
                        onPressed: onFavoriteTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 26,
                          height: 26,
                        ),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
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
                    '$sport   •   $distance',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        rate,
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

class _CommunityEventCard extends StatelessWidget {
  const _CommunityEventCard({
    required this.event,
    this.onTap,
  });

  final NearbyEvent event;
  final VoidCallback? onTap;

  Color _eventColor(String sport) =>
      const {
        'Badminton': Color(0xFF477D82),
        'Tennis': Color(0xFFB77B64),
        'Basketball': Color(0xFFC9A878),
        'Football': Color(0xFF5E8C61),
      }[sport] ??
      const Color(0xFF4C7895);

  IconData _eventIcon(String sport) =>
      const {
        'Badminton': Icons.sports_tennis,
        'Tennis': Icons.sports_tennis,
        'Basketball': Icons.sports_basketball,
        'Football': Icons.sports_soccer,
        'Swimming': Icons.pool,
        'Cricket': Icons.sports_cricket,
        'Running': Icons.directions_run,
      }[sport] ??
      Icons.sports;

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.sport);
    final icon = _eventIcon(event.sport);
    final isCancelled = event.status.toLowerCase() == 'cancelled';
    final isFull = event.isFull;

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
                        colors: [
                          color,
                          color.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: event.imageUrl.isNotEmpty
                        ? (event.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                event.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    icon,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: 54,
                                  ),
                                ),
                              )
                            : Image.network(
                                event.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    icon,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: 54,
                                  ),
                                ),
                              ))
                        : Center(
                            child: Icon(
                              icon,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 54,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCancelled
                                ? Icons.cancel_outlined
                                : Icons.event_available,
                            size: 13,
                            color: isCancelled
                                ? const Color(0xFFE14C4C)
                                : AppColors.primaryTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCancelled
                                  ? const Color(0xFFE14C4C)
                                  : AppColors.primaryTeal,
                            ),
                          ),
                        ],
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event.date}${event.time.isNotEmpty ? '  •  ${event.time}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          event.location.isNotEmpty
                              ? event.location
                              : event.facility,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? const Color(0xFFF3F4F6)
                          : (isFull
                              ? const Color(0xFFFFEEEE)
                              : AppColors.availableBg),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCancelled
                          ? 'Cancelled'
                          : (isFull ? 'Full' : 'Join event'),
                      style: TextStyle(
                        color: isCancelled
                            ? AppColors.textSecondary
                            : (isFull
                                ? const Color(0xFFE14C4C)
                                : AppColors.available),
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
      ),
    );
  }
}
