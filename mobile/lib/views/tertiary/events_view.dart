
import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/app_services.dart';
import '../../utils/tertiary_navigation.dart';
import '../../widgets/tertiary/nav_bar.dart';
import '../../widgets/tertiary/nearby_event_card.dart';
import '../../widgets/tertiary/filter_chip.dart';
import '../../widgets/tertiary/date_selector.dart';
import 'event_details_view.dart';
import '../../models/contact_request_model.dart';
import 'my_requests_view.dart';
import 'notifications_view.dart';

class EventsView extends StatefulWidget {
  final String? initialQuery;

  const EventsView({super.key, this.initialQuery});

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  // Events corresponds to index 1 in TertiaryNavBar.
  static const int _tabIndex = 1;

  static const Color _background = Color(0xFFF5F6F8);
  static const Color _heading = Color(0xFF0F2A44);
  static const Color _subtext = Color(0xFF8A93A3);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedSport;
  String? _selectedLocation;
  String? _selectedEventType;
  bool _onlySaved = false;
  bool _dateFilterEnabled = true;

  bool _isLoading = true;
  List<NearbyEvent> _allEvents = [];

  final List<DateTime> _availableDates = [
    DateTime(2026, 9, 18), // Fri
    DateTime(2026, 9, 19), // Sat
    DateTime(2026, 9, 20), // Sun — matches prototype's selected date
    DateTime(2026, 9, 21), // Mon
    DateTime(2026, 9, 22), // Tue
  ];
  late DateTime _selectedDate = _availableDates[2];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    appServices.bookmarkService.addListener(_onBookmarksChanged);
    _loadEvents();
  }

  void _onBookmarksChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadEvents() async {
    final events = await appServices.eventRepository.getEvents();
    if (!mounted) return;
    setState(() {
      _allEvents = events;
      _isLoading = false;
    });
  }

  List<String> get _sportOptions =>
      _allEvents.map((e) => e.sport).toSet().toList();
  List<String> get _locationOptions =>
      _allEvents.map((e) => e.location).toSet().toList();
  List<String> get _eventTypeOptions =>
      _allEvents.map((e) => e.eventType).toSet().toList();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // All four filters + search combine with AND logic, per spec.
  List<NearbyEvent> get _filteredEvents {
    final query = _searchQuery.trim().toLowerCase();

    return _allEvents.where((event) {
      final matchesSearch = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.sport.toLowerCase().contains(query) ||
          event.location.toLowerCase().contains(query) ||
          event.facility.toLowerCase().contains(query);

      final matchesSport =
          _selectedSport == null || event.sport == _selectedSport;
      final matchesLocation =
          _selectedLocation == null || event.location == _selectedLocation;
      final matchesType =
          _selectedEventType == null || event.eventType == _selectedEventType;
      final matchesSaved =
          !_onlySaved || appServices.bookmarkService.isSaved(event.id);
      final matchesDate =
          !_dateFilterEnabled || _isSameDay(event.eventDate, _selectedDate);

      return matchesSearch &&
          matchesSport &&
          matchesLocation &&
          matchesType &&
          matchesSaved &&
          matchesDate;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _onlySaved ||
      _selectedSport != null ||
      _selectedLocation != null ||
      _selectedEventType != null ||
      !_dateFilterEnabled;

  void _resetFilters() {
    setState(() {
      _onlySaved = false;
      _selectedSport = null;
      _selectedLocation = null;
      _selectedEventType = null;
      _dateFilterEnabled = true;
    });
  }

  Future<void> _showOptionsSheet({
    required String title,
    required List<String> options,
    required String? current,
    required ValueChanged<String?> onSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _heading,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text('All'),
                trailing: current == null
                    ? const Icon(Icons.check, color: Color(0xFF2E8B57))
                    : null,
                onTap: () {
                  onSelected(null);
                  Navigator.pop(context);
                },
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: current == option
                      ? const Icon(Icons.check, color: Color(0xFF2E8B57))
                      : null,
                  onTap: () {
                    onSelected(option);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _onNavTap(int index) {
    handleTertiaryNavTap(
      context: context,
      tappedIndex: index,
      currentIndex: _tabIndex,
    );
  }

  @override
  void dispose() {
    appServices.bookmarkService.removeListener(_onBookmarksChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;

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
                  SliverToBoxAdapter(child: _buildFilterChips()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(
                    child: DateSelector(
                      dates: _availableDates,
                      selectedDate: _selectedDate,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildSectionHeader(events.length)),
                  if (events.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final event = events[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: NearbyEventCard(
                                event: event,
                                showActions: true,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsView(event: event),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: events.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      // --- Reused global nav bar, not re-implemented here -----------------
      bottomNavigationBar:
          TertiaryNavBar(currentIndex: _tabIndex, onItemSelected: _onNavTap),
    );
  }

  Widget _buildHeader() {
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
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
                'Events & Schedules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _heading,
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyRequestsView()),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE7EAF0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 15,
                        color: _heading,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View requests',
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
              const SizedBox(width: 8),
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
                    border: Border.all(color: const Color(0xFFE7EAF0)),
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
            hintText: 'Search events, sports or facilities',
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          EventFilterChip(
            label: _selectedSport ?? 'Sport',
            icon: Icons.filter_list_rounded,
            isActive: true, // matches prototype: Sport shown active by default
            showCaret: true,
            onTap: () => _showOptionsSheet(
              title: 'Sport',
              options: _sportOptions,
              current: _selectedSport,
              onSelected: (value) => setState(() => _selectedSport = value),
            ),
          ),
          const SizedBox(width: 10),
          ListenableBuilder(
            listenable: appServices.contactRequestService,
            builder: (context, _) {
              final requests = appServices.contactRequestService.myRequests;
              final count = requests.length;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EventFilterChip(
                    label: count > 0 ? 'My Requests ($count)' : 'My Requests',
                    icon: Icons.assignment_outlined,
                    isActive: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyRequestsView()),
                    ),
                  ),
                  if (requests.isNotEmpty) ...[
                    for (final req in requests) ...[
                      const SizedBox(width: 10),
                      EventFilterChip(
                        label: req.message.length > 20
                            ? '${req.message.substring(0, 18)}...'
                            : req.message,
                        icon: req.type == ContactRequestType.accessibilityRequest
                            ? Icons.accessible_rounded
                            : Icons.chat_bubble_outline_rounded,
                        isActive: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MyRequestsView(initialRequestId: req.id),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
          const SizedBox(width: 10),
          EventFilterChip(
            label: 'Saved only',
            icon: _onlySaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            isActive: _onlySaved,
            onTap: () => setState(() => _onlySaved = !_onlySaved),
          ),
          const SizedBox(width: 10),
          EventFilterChip(
            label: 'Date',
            isActive: !_dateFilterEnabled,
            onTap: () =>
                setState(() => _dateFilterEnabled = !_dateFilterEnabled),
          ),
          const SizedBox(width: 10),
          EventFilterChip(
            label: _selectedLocation ?? 'Location',
            isActive: _selectedLocation != null,
            showCaret: true,
            onTap: () => _showOptionsSheet(
              title: 'Location',
              options: _locationOptions,
              current: _selectedLocation,
              onSelected: (value) => setState(() => _selectedLocation = value),
            ),
          ),
          const SizedBox(width: 10),
          EventFilterChip(
            label: _selectedEventType ?? 'Event type',
            isActive: _selectedEventType != null,
            showCaret: true,
            onTap: () => _showOptionsSheet(
              title: 'Event type',
              options: _eventTypeOptions,
              current: _selectedEventType,
              onSelected: (value) => setState(() => _selectedEventType = value),
            ),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 10),
            EventFilterChip(
              label: 'Clear',
              icon: Icons.close_rounded,
              onTap: _resetFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Text(
        'Upcoming Events${count > 0 ? ' ($count)' : ''}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _heading,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded,
              size: 40, color: Color(0xFFC3C9D3)),
          const SizedBox(height: 12),
          const Text(
            'No events match your filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting search, filters, or the selected date.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: _subtext),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset filters'),
          ),
        ],
      ),
    );
  }
}