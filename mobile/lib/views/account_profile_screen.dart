import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/booking.dart';
import '../services/account_settings_service.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'manager/manager_facilities_screen.dart';
import 'my_bookings_screen.dart';
import 'tertiary/placeholder_view.dart';
import '../widgets/tertiary/nav_bar.dart';
import 'tertiary/home_view.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, this.communityMode = false});

  final bool communityMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: AccountProfileContent()),
      bottomNavigationBar: communityMode
          ? TertiaryNavBar(
              currentIndex: 4,
              onItemSelected: (index) {
                if (index == 4) return;
                final Widget destination = switch (index) {
                  0 => const TertiaryHomeView(),
                  2 => const ExploreScreen(),
                  _ => TertiaryPlaceholderView(
                      title: index == 1 ? 'Events' : 'Notifications',
                    ),
                };
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(builder: (_) => destination),
                );
              },
            )
          : AppBottomNav(
              currentIndex: 4,
              onItemSelected: (index) {
                if (index == 4) return;
                final Widget destination = switch (index) {
                  0 => const HomeScreen(),
                  1 => const ExploreScreen(),
                  2 => const MyBookingsScreen(),
                  _ => const TertiaryPlaceholderView(title: 'Notifications'),
                };
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(builder: (_) => destination),
                );
              },
            ),
    );
  }
}

class AccountProfileContent extends StatefulWidget {
  const AccountProfileContent({
    super.key,
    this.managerPortal = false,
    this.onOpenManagerBookings,
  });

  final bool managerPortal;
  final VoidCallback? onOpenManagerBookings;

  @override
  State<AccountProfileContent> createState() => _AccountProfileContentState();
}

class _AccountProfileContentState extends State<AccountProfileContent> {
  final _searchController = TextEditingController();
  static const _tabs = ['Account', 'Preferences', 'Payments', 'Support'];

  int _selectedTab = 0;
  bool _loading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  Map<String, dynamic> _profile = {};
  List<Booking> _bookings = [];
  Set<String> _favorites = {};
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final authUser = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> profile = {
      'fullName': authUser?.displayName ?? authUser?.email?.split('@').first ?? 'User',
      'email': authUser?.email ?? '',
      'role': widget.managerPortal ? 'Facility Manager' : 'Player',
      'phone': '',
      'address': '',
    };
    String? loadError;
    try {
      profile = await ApiService.fetchUserProfile() ?? profile;
    } catch (error) {
      loadError = error.toString();
    }

    List<Booking> bookings = [];
    try {
      final rawBookings = await ApiService.fetchBookings();
      bookings = rawBookings
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromJson)
          .toList();
    } catch (_) {
      // The profile itself remains available when booking history is offline.
    }

    final favorites = await FavoritesService.loadFavorites();
    final notifications = await AccountSettingsService.loadNotificationsEnabled();
    final darkMode = await AccountSettingsService.readDarkMode();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _bookings = bookings;
      _favorites = favorites;
      _notificationsEnabled = notifications;
      _darkModeEnabled = darkMode;
      _loadError = loadError;
      _loading = false;
    });
  }

  String get _name => _profile['fullName']?.toString().trim().isNotEmpty == true
      ? _profile['fullName'].toString()
      : 'User';

  String get _email => _profile['email']?.toString() ?? '';
  String get _role => _profile['role']?.toString() ?? 'Player';
  bool get _isManager => _role == 'Facility Manager';
  bool get _isPlayer => _role == 'Player';
  bool get _verified => _isManager
      ? _profile['isApproved'] == true
      : (FirebaseAuth.instance.currentUser?.emailVerified ?? false);

  bool _matchesSearch(String text) {
    final query = _searchController.text.trim().toLowerCase();
    return query.isEmpty || text.toLowerCase().contains(query);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await AccountSettingsService.setNotificationsEnabled(value);
    _showMessage(value ? 'Notifications enabled' : 'Notifications disabled');
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkModeEnabled = value);
    await AccountSettingsService.setDarkMode(value);
  }

  Future<void> _editPersonalInfo() async {
    final nameController = TextEditingController(text: _name);
    final phoneController = TextEditingController(
      text: _profile['phone']?.toString() ?? '',
    );
    final addressController = TextEditingController(
      text: _profile['address']?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personal Information'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Enter your name' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email: $_email', style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (save == true) {
      try {
        final updated = await ApiService.updateUserProfile(
          fullName: nameController.text.trim(),
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
        );
        if (mounted) {
          setState(() => _profile = updated);
          _showMessage('Profile updated');
        }
      } catch (error) {
        _showMessage('Could not update profile: $error');
      }
    }
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  void _openBookings() {
    if (_isManager && widget.onOpenManagerBookings != null) {
      widget.onOpenManagerBookings!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const MyBookingsScreen()),
    );
  }

  Future<void> _openPayments() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isManager ? 'Payout & Merchant Account' : 'Payment Methods',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_isManager ? Icons.account_balance_outlined : Icons.lock_outline),
                title: Text(_isManager ? 'Payout assistance' : 'Secure card payments'),
                subtitle: Text(_isManager
                    ? 'Contact support for payout and merchant account questions.'
                    : 'Card details are entered securely through Stripe at checkout.'),
                onTap: _isManager ? _contactSupport : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Booking payment history'),
                subtitle: const Text('Review payments with your bookings.'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openBookings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _contactSupport() async {
    await SharePlus.instance.share(
      ShareParams(
        title: 'SportSpace Support',
        subject: 'SportSpace support request',
        text: 'I need help with SportSpace.\n\nAccount: $_email',
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = Theme.of(context).colorScheme.onSurface;
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ColoredBox(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surface
                      : const Color(0xFFF3F5F8),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                    children: [
                      _buildSearch(),
                      const SizedBox(height: 12),
                      _buildTabs(),
                      if (_loadError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Showing Firebase account details. Profile service unavailable.',
                          style: TextStyle(color: roleColor.withValues(alpha: .7), fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildTabContent(),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildHeader() {
    final initials = _name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final memberships = _profile['assignedVenues'];
    final facilitiesCount = memberships is List ? memberships.length : 0;
    final createdAt = DateTime.tryParse(_profile['createdAt']?.toString() ?? '');
    final joined = createdAt == null
        ? '—'
        : '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      color: const Color(0xFF102F50),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _selectedTab = 1),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: .14),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notification preferences',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF477EAA),
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(_email, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFB8C7D8), fontSize: 11)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF164C4D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _verified ? '✓ Verified Member' : _role,
                        style: const TextStyle(color: Color(0xFF71E0B1), fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('Bookings', _bookings.length.toString()),
              const SizedBox(width: 8),
              _statCard('Favourites', _favorites.length.toString()),
              const SizedBox(width: 8),
              _statCard(_isManager ? 'Facilities' : 'Member since', _isManager ? '$facilitiesCount' : joined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: const Color(0xFF294766), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFC1D0DE), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search account settings',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedTab == index;
          return ChoiceChip(
            label: Text(_tabs[index]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedTab = index),
            selectedColor: const Color(0xFF102F50),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: BorderSide(color: selected ? const Color(0xFF102F50) : Colors.black12),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_selectedTab) {
      0 => _buildAccountTab(),
      1 => _buildPreferencesTab(),
      2 => _buildPaymentsTab(),
      _ => _buildSupportTab(),
    };
  }

  Widget _buildAccountTab() {
    final tiles = <Widget>[
      if (_matchesSearch('Personal Information Name Phone Address Email'))
        _profileTile(
          Icons.person_outline_rounded,
          const Color(0xFF1673D1),
          const Color(0xFFE6F1FD),
          'Personal Information',
          '$_name • ${_profile['phone']?.toString().isNotEmpty == true ? _profile['phone'] : 'Add phone'} • ${_profile['address']?.toString().isNotEmpty == true ? _profile['address'] : 'Add address'}',
          _editPersonalInfo,
        ),
      if ((_isManager || _isPlayer) &&
          _matchesSearch('My Bookings Upcoming Past Cancelled'))
        _profileTile(Icons.calendar_month_outlined, const Color(0xFF13A76B), const Color(0xFFE7F8F0),
            'My Bookings', 'Upcoming • Past • Cancelled', _openBookings),
      if (_isManager && _matchesSearch('Facility Management Courts Pricing Availability'))
        _profileTile(Icons.sports_tennis_rounded, const Color(0xFF13A76B), const Color(0xFFE7F8F0),
            'Facility Management', 'Manage courts, pricing and availability', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ManagerFacilitiesScreen()));
            }),
      if (_isManager && _matchesSearch('Payout Merchant Account Payments'))
        _profileTile(Icons.account_balance_outlined, const Color(0xFFF18B24), const Color(0xFFFFF1E3),
            'Payout & Merchant Account', 'Payout account assistance', _openPayments),
      if (_isPlayer && _matchesSearch('Payment Methods Card'))
        _profileTile(Icons.credit_card_outlined, const Color(0xFFF18B24), const Color(0xFFFFF1E3),
            'Payment Methods', 'Secure card payments through Stripe', _openPayments),
      if (_matchesSearch('Sign Out Logout'))
        _profileTile(Icons.logout_rounded, const Color(0xFFD94848), const Color(0xFFFFEAEA),
            'Sign Out', 'Sign out of this SportSpace account', _signOut),
    ];
    return _section('Account', tiles);
  }

  Widget _buildPreferencesTab() {
    final tiles = <Widget>[
      if (_matchesSearch('Notifications Event Booking Alerts'))
        _switchTile(Icons.notifications_none_rounded, const Color(0xFF8746E8), const Color(0xFFF1EAFE),
            'Notifications', 'Event and booking alerts', _notificationsEnabled, _toggleNotifications),
      if (_matchesSearch('Dark Mode Theme'))
        _switchTile(Icons.dark_mode_outlined, const Color(0xFF0AA9A8), const Color(0xFFE4F8F8),
            'Dark Mode', 'Use the dark appearance throughout the app', _darkModeEnabled, _toggleDarkMode),
    ];
    return _section('Preferences', tiles);
  }

  Widget _buildPaymentsTab() {
    if (_isManager) {
      return _section('Payments', [
        if (_matchesSearch('Payout Merchant Account Support'))
          _profileTile(
            Icons.account_balance_outlined,
            const Color(0xFFF18B24),
            const Color(0xFFFFF1E3),
            'Payout & Merchant Account',
            'Contact support for payout assistance',
            _openPayments,
          ),
      ]);
    }
    final tiles = <Widget>[
      if (_matchesSearch('Secure Card Payments Stripe'))
        _profileTile(Icons.credit_card_outlined, const Color(0xFFF18B24), const Color(0xFFFFF1E3),
            'Secure Card Payments', 'Cards are entered securely at checkout', _openPayments),
      if (_matchesSearch('Payment History Bookings'))
        _profileTile(Icons.receipt_long_outlined, const Color(0xFF1673D1), const Color(0xFFE6F1FD),
            'Payment History', 'View payment details with your bookings', _openBookings),
    ];
    return _section('Payments', tiles);
  }

  Widget _buildSupportTab() {
    final tiles = <Widget>[
      if (_matchesSearch('Contact Support Help'))
        _profileTile(Icons.support_agent_rounded, const Color(0xFF1673D1), const Color(0xFFE6F1FD),
            'Contact Support', 'Share a support request with your account email', _contactSupport),
      if (_matchesSearch('About SportSpace'))
        _profileTile(Icons.info_outline_rounded, const Color(0xFF13A76B), const Color(0xFFE7F8F0),
            'About SportSpace', 'Sports facility booking and community platform', () {
              showAboutDialog(context: context, applicationName: 'SportSpace');
            }),
    ];
    return _section('Support', tiles);
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (tiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(child: Text('No matching settings', style: TextStyle(color: Theme.of(context).hintColor))),
          )
        else
          Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(children: tiles),
          ),
      ],
    );
  }

  Widget _profileTile(IconData icon, Color color, Color background, String title,
      String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: _iconBox(icon, color, background),
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB9C4D1)),
    );
  }

  Widget _switchTile(IconData icon, Color color, Color background, String title,
      String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      onTap: () => onChanged(!value),
      leading: _iconBox(icon, color, background),
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _iconBox(IconData icon, Color color, Color background) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: color, size: 21),
    );
  }
}
