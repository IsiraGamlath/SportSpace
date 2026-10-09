import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../login_screen.dart';
import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import '../../utils/tertiary_navigation.dart';
import '../../widgets/tertiary/filter_chip.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/profile_setting_tile.dart';
import '../../widgets/tertiary/profile_stat_card.dart';
import 'contact_accessibility_view.dart';
import 'event_details_view.dart';
import 'events_view.dart';
import 'notifications_view.dart';
import 'personal_information_view.dart';
import '../../services/api_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../home_screen.dart';
import '../explore_screen.dart';
import '../my_bookings_screen.dart';

class ProfileView extends StatefulWidget {
  final String role;
  const ProfileView({super.key, this.role = 'Tertiary'});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Profile corresponds to index 4 in TertiaryNavBar.
  static const int _tabIndex = 4;

  // Local constants — replace with your app theme if available.
  static const Color _navy = Color(0xFF0D2B4E);
  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);
  static const Color _cardBorder = Color(0xFFE7EAF0);

  // Payments filter chip removed per requirement 4.
  static const List<String> _categories = [
    'All',
    'Account',
    'Saved Events',
    'Preferences',
    'Support',
  ];
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<NearbyEvent> _allEvents = [];
  bool _notificationsEnabled = true; // initially ON, per spec
  bool _darkModeEnabled = false; // initially OFF, per spec

  String _userName = '';
  String _userEmail = '';
  String _userInitials = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadEvents();
    appServices.bookmarkService.addListener(_onBookmarksChanged);
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ApiService.fetchUserProfile();
      if (!mounted) return;
      
      String name = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
      String email = FirebaseAuth.instance.currentUser?.email ?? '';
      
      if (profile != null) {
        name = profile['fullName'] ?? profile['name'] ?? name;
        email = profile['email'] ?? email;
      }
      
      String initials = 'U';
      final names = name.trim().split(RegExp(r'\s+'));
      if (names.length > 1) {
        initials = '${names.first[0]}${names.last[0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name.substring(0, 1).toUpperCase();
      }
      
      setState(() {
        _userName = name;
        _userEmail = email;
        _userInitials = initials;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
        _userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
        final n = _userName.trim().split(RegExp(r'\s+'));
        _userInitials = n.length > 1 ? '${n.first[0]}${n.last[0]}'.toUpperCase() : (_userName.isNotEmpty ? _userName.substring(0, 1).toUpperCase() : 'U');
      });
    }
  }

  @override
  void dispose() {
    appServices.bookmarkService.removeListener(_onBookmarksChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onBookmarksChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadEvents() async {
    final events = await appServices.eventRepository.getEvents();
    if (!mounted) return;
    setState(() => _allEvents = events);
  }

  List<NearbyEvent> get _savedEvents {
    return _allEvents
        .where((e) => appServices.bookmarkService.isSaved(e.id))
        .toList();
  }

  bool _matchesSearch(String text) {
    if (_searchQuery.trim().isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery.trim().toLowerCase());
  }

  bool get _matchesAccount =>
      _matchesSearch('account') ||
      _matchesSearch('personal information') ||
      _matchesSearch('name') ||
      _matchesSearch('phone') ||
      _matchesSearch('address') ||
      _matchesSearch('profile');

  bool get _matchesSavedEvents =>
      _matchesSearch('saved') ||
      _matchesSearch('events') ||
      _matchesSearch('bookmark') ||
      _savedEvents.any((e) =>
          _matchesSearch(e.title) ||
          _matchesSearch(e.sport) ||
          _matchesSearch(e.facility));

  bool get _matchesPreferences =>
      _matchesSearch('preferences') ||
      _matchesSearch('notifications') ||
      _matchesSearch('dark mode') ||
      _matchesSearch('alerts');

  bool get _matchesSupport =>
      _matchesSearch('support') ||
      _matchesSearch('accessibility') ||
      _matchesSearch('contact') ||
      _matchesSearch('help') ||
      _matchesSearch('enquiries');

  bool get _showAccount =>
      (_selectedCategory == 'All' || _selectedCategory == 'Account') &&
      _matchesAccount;

  bool get _showSavedEvents =>
      (_selectedCategory == 'All' || _selectedCategory == 'Saved Events') &&
      _matchesSavedEvents;

  bool get _showPreferences =>
      (_selectedCategory == 'All' || _selectedCategory == 'Preferences') &&
      _matchesPreferences;

  bool get _showSupport =>
      (_selectedCategory == 'All' || _selectedCategory == 'Support') &&
      _matchesSupport;

  bool get _hasAnyVisibleSection =>
      _showAccount || _showSavedEvents || _showPreferences || _showSupport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      // Header sits flush against the status bar (dark navy runs behind
      // it), so SafeArea is applied inside _buildHeader instead.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 14),
                  _buildCategoryChips(),
                  const SizedBox(height: 20),
                  if (!_hasAnyVisibleSection)
                    _buildNoMatchesFound()
                  else ...[
                    if (_showAccount) ...[
                      _buildAccountSection(context),
                      const SizedBox(height: 24),
                    ],
                    if (_showSavedEvents) ...[
                      _buildSavedEventsSection(context),
                      const SizedBox(height: 24),
                    ],
                    if (_showPreferences) ...[
                      _buildPreferencesSection(),
                      const SizedBox(height: 24),
                    ],
                    if (_showSupport) ...[
                      _buildSupportSection(context),
                      const SizedBox(height: 24),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Reused global nav bar, not re-implemented here -----------------
      bottomNavigationBar: widget.role == 'Player'
          ? AppBottomNav(
              currentIndex: 4,
              onItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                } else if (index == 1) {
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
                }
              },
            )
          : TertiaryNavBar(
              currentIndex: _tabIndex,
              onItemSelected: (index) => handleTertiaryNavTap(
                context: context,
                tappedIndex: index,
                currentIndex: _tabIndex,
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final canPop = Navigator.of(context).canPop();

    return Container(
      width: double.infinity,
      color: _navy,
      padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF3D6F9C),
                child: Text(
                  _userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF9FB6CF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2FAE6A).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 12, color: Color(0xFF4ADE80)),
                          SizedBox(width: 5),
                          Text(
                            'Verified Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4ADE80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ProfileStatCard(
                value: '${_savedEvents.length}',
                label: 'Saved Events',
              ),
              const SizedBox(width: 10),
              const ProfileStatCard(value: '4', label: 'Notifications'),
              const SizedBox(width: 10),
              const ProfileStatCard(value: '8', label: 'Facilities'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          prefixIcon:
              const Icon(Icons.search, size: 20, color: Color(0xFF9AA4B2)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: Color(0xFF9AA4B2)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          hintText: 'Search account settings',
          hintStyle: const TextStyle(fontSize: 13.5, color: _subtext),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return EventFilterChip(
            label: category,
            isActive: isSelected,
            showCaret: category == 'Account',
            onTap: () {
              setState(() {
                if (isSelected && category != 'All') {
                  _selectedCategory = 'All';
                } else {
                  _selectedCategory = category;
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildNoMatchesFound() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 36, color: Color(0xFF9AA4B2)),
          const SizedBox(height: 10),
          Text(
            'No results matching "$_searchQuery"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _heading,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try checking for typos or clear the search to see all settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _subtext),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategory = 'All';
              });
            },
            child: const Text('Reset search & filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _heading,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          // ClipRRect so the InkWell ripple stays inside the rounded card.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ProfileSettingTile(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              subtitle: 'Name • Phone • Address',
              trailing: const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Color(0xFFC3C9D3)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationView(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedEventsSection(BuildContext context) {
    final saved = _savedEvents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Events (${saved.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _heading,
              ),
            ),
            if (saved.isNotEmpty)
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EventsView()),
                ),
                child: const Text(
                  'Explore more',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E8B57),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (saved.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.bookmark_border_rounded,
                    size: 32, color: Color(0xFF9AA4B2)),
                const SizedBox(height: 8),
                const Text(
                  'No saved events yet',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _heading,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bookmark events in Events & Schedules to quickly find them here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _subtext),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EventsView()),
                  ),
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('Browse Events'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          )
        else
          ...saved.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _cardBorder),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_rounded,
                        color: Color(0xFF2E8B57), size: 22),
                  ),
                  title: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _heading,
                    ),
                  ),
                  subtitle: Text(
                    '${event.sport} • ${event.date}',
                    style: const TextStyle(fontSize: 12, color: _subtext),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_remove_rounded,
                        color: Color(0xFFE05252), size: 20),
                    tooltip: 'Unsave',
                    onPressed: () {
                      appServices.bookmarkService.unsave(event.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Removed "${event.title}" from saved events'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailsView(event: event),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _heading,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            children: [
              ProfileSettingTile(
                icon: Icons.notifications_none_rounded,
                iconColor: const Color(0xFF7C4BD6),
                iconBg: const Color(0xFFF2ECFC),
                title: 'Notifications',
                subtitle: 'Event & booking alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: _navy,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F3F6)),
              ProfileSettingTile(
                icon: Icons.nightlight_round,
                iconColor: const Color(0xFF189B9B),
                iconBg: const Color(0xFFE3F7F7),
                title: 'Dark Mode',
                trailing: Switch(
                  value: _darkModeEnabled,
                  activeThumbColor: _navy,
                  onChanged: (value) =>
                      setState(() => _darkModeEnabled = value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Support & Accessibility',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _heading,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ProfileSettingTile(
              icon: Icons.contact_support_outlined,
              iconColor: const Color(0xFF1D7A6B),
              iconBg: const Color(0xFFE3F3EC),
              title: 'Contact & Accessibility',
              subtitle: 'Enquiries • Accessibility requests • Help',
              trailing: const Icon(Icons.chevron_right_rounded,
                  size: 20, color: Color(0xFFC3C9D3)),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ContactAccessibilityView(
                    facilityId: 'general',
                    facilityName: 'SportSpace Support & Facilities',
                    phone: '+94 11 234 5678',
                    email: 'support@sportspace.lk',
                    address: 'Independence Square, Colombo 07',
                    openingHours: '6:00 AM – 10:00 PM',
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Do you want to sign out of SportSpace?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await FirebaseAuth.instance.signOut();
                        } catch (_) {}
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE05252),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: Color(0xFFE05252),
            ),
            label: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFE05252),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFDECEC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}