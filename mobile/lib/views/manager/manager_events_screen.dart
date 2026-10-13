import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/api_service.dart';
import '../../services/app_services.dart';
import '../../theme/manager_colors.dart';
import 'manager_create_event_screen.dart';

class ManagerEventsScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialAssignedFacilities;

  const ManagerEventsScreen({
    super.key,
    this.initialAssignedFacilities,
  });

  @override
  State<ManagerEventsScreen> createState() => _ManagerEventsScreenState();
}

class _ManagerEventsScreenState extends State<ManagerEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String? _selectedFacilityId;

  bool _isLoading = true;
  List<NearbyEvent> _events = [];
  List<Map<String, dynamic>> _assignedFacilities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAssignedFacilities != null &&
        widget.initialAssignedFacilities!.isNotEmpty) {
      _assignedFacilities =
          List<Map<String, dynamic>>.from(widget.initialAssignedFacilities!);
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_assignedFacilities.isEmpty) {
        final facs = await ApiService.fetchManagerFacilities();
        if (mounted && facs.isNotEmpty) {
          _assignedFacilities = facs;
        }
      }

      final allEvents = await appServices.eventRepository.getEvents();

      if (mounted) {
        setState(() {
          _events = allEvents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<NearbyEvent> get _filteredEvents {
    final query = _searchQuery.trim().toLowerCase();

    // Collect IDs of assigned facilities
    final assignedIds = _assignedFacilities
        .map((f) => f['id']?.toString() ?? f['_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final assignedNames = _assignedFacilities
        .map((f) => f['name']?.toString().toLowerCase().trim() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();

    return _events.where((event) {
      // 1. Match Manager's facilities (if manager has assigned facilities)
      if (assignedIds.isNotEmpty || assignedNames.isNotEmpty) {
        final matchesId = assignedIds.contains(event.facilityId);
        final matchesName = assignedNames.contains(event.facility.toLowerCase().trim());
        if (!matchesId && !matchesName) {
          return false;
        }
      }

      // 2. Specific facility filter tab
      if (_selectedFacilityId != null && _selectedFacilityId != 'All') {
        if (event.facilityId != _selectedFacilityId) {
          return false;
        }
      }

      // 3. Status filter
      if (_selectedStatus != 'All' && event.status != _selectedStatus) {
        return false;
      }

      // 4. Search query
      if (query.isNotEmpty) {
        final matchesTitle = event.title.toLowerCase().contains(query);
        final matchesSport = event.sport.toLowerCase().contains(query);
        final matchesFacility = event.facility.toLowerCase().contains(query);
        final matchesLocation = event.location.toLowerCase().contains(query);
        if (!matchesTitle && !matchesSport && !matchesFacility && !matchesLocation) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openCreateEvent() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ManagerCreateEventScreen(
          assignedFacilities: _assignedFacilities,
        ),
      ),
    ).then((created) {
      if (created == true) {
        _loadData();
      }
    });
  }

  void _openEditEvent(NearbyEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ManagerCreateEventScreen(
          assignedFacilities: _assignedFacilities,
          eventToEdit: event,
        ),
      ),
    ).then((updated) {
      if (updated == true) {
        _loadData();
      }
    });
  }

  Future<void> _confirmDeleteEvent(NearbyEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: ManagerColors.red, size: 24),
              SizedBox(width: 10),
              Text(
                'Delete Event',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ManagerColors.navyDark,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "${event.title}"? This will cancel all RSVPs and remove it from the public schedule.',
            style: const TextStyle(fontSize: 14, color: ManagerColors.navy, height: 1.4),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel', style: TextStyle(color: ManagerColors.secondaryText)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ManagerColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await appServices.eventRepository.deleteEvent(event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Event "${event.title}" deleted.'),
                  ),
                ],
              ),
              backgroundColor: ManagerColors.navyDark,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete event: $e'),
              backgroundColor: ManagerColors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleCancelEvent(NearbyEvent event) async {
    final willCancel = event.status != 'Cancelled';
    final actionName = willCancel ? 'Cancel' : 'Re-open';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '$actionName Event?',
            style: const TextStyle(fontWeight: FontWeight.w800, color: ManagerColors.navyDark),
          ),
          content: Text(
            willCancel
                ? 'Mark "${event.title}" as Cancelled? Registered participants will be notified.'
                : 'Re-open "${event.title}" for registrations?',
            style: const TextStyle(fontSize: 13.5, color: ManagerColors.navy),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: willCancel ? ManagerColors.amber : ManagerColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(actionName),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (willCancel) {
        await appServices.eventRepository.cancelEvent(event.id);
      } else {
        await appServices.eventRepository.updateEvent(event.copyWith(status: 'Open'));
      }
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    return Scaffold(
      backgroundColor: ManagerColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ManagerColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Events',
          style: TextStyle(
            color: ManagerColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ElevatedButton.icon(
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ManagerColors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: ManagerColors.teal,
          child: Column(
            children: [
              // Search & Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: ManagerColors.pageBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ManagerColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search your events, sports or venues...',
                          hintStyle: const TextStyle(fontSize: 13, color: ManagerColors.secondaryText),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ManagerColors.secondaryText),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Status Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('All'),
                          _buildStatusChip('Open'),
                          _buildStatusChip('Confirmed'),
                          _buildStatusChip('Cancelled'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Events List View
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: ManagerColors.teal),
                      )
                    : filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return _buildEventItemCard(filtered[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _selectedStatus = status);
        },
        selectedColor: ManagerColors.teal,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : ManagerColors.navy,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? ManagerColors.teal : ManagerColors.border,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildEventItemCard(NearbyEvent event) {
    final isCancelled = event.status == 'Cancelled';
    final isFull = event.isFull;

    Color badgeBg;
    Color badgeText;
    if (isCancelled) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = ManagerColors.red;
    } else if (isFull) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = ManagerColors.amber;
    } else {
      badgeBg = ManagerColors.tealSoft;
      badgeText = ManagerColors.teal;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ManagerColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sport Tag & Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ManagerColors.tealSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_tennis_rounded, size: 14, color: ManagerColors.teal),
                          const SizedBox(width: 4),
                          Text(
                            event.sport,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: ManagerColors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${event.eventType}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ManagerColors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Title & Facility Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ManagerColors.navyDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stadium_rounded, size: 15, color: ManagerColors.secondaryText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${event.facility} (${event.location})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: ManagerColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: ManagerColors.secondaryText),
                    const SizedBox(width: 6),
                    Text(
                      '${event.date} · ${event.time}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: ManagerColors.navyDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RSVP Capacity Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ManagerColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RSVP Participants',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ManagerColors.navy,
                        ),
                      ),
                      Text(
                        '${event.participantCount} / ${event.capacity} Filled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isFull ? ManagerColors.red : ManagerColors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: event.capacity > 0
                          ? (event.participantCount / event.capacity).clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 6,
                      backgroundColor: ManagerColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFull ? ManagerColors.red : ManagerColors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: ManagerColors.border),

          // Action Buttons: Edit, Toggle Cancel, Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                TextButton.icon(
                  onPressed: () => _openEditEvent(event),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: ManagerColors.navy),
                  label: const Text('Edit', style: TextStyle(color: ManagerColors.navy, fontWeight: FontWeight.w700, fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
                const SizedBox(width: 4),

                // Toggle cancel/reopen
                TextButton.icon(
                  onPressed: () => _toggleCancelEvent(event),
                  icon: Icon(
                    isCancelled ? Icons.replay_rounded : Icons.block_rounded,
                    size: 16,
                    color: isCancelled ? ManagerColors.teal : ManagerColors.amber,
                  ),
                  label: Text(
                    isCancelled ? 'Re-open' : 'Cancel',
                    style: TextStyle(
                      color: isCancelled ? ManagerColors.teal : ManagerColors.amber,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                ),
                const SizedBox(width: 4),

                // Delete button
                IconButton(
                  tooltip: 'Delete Event',
                  icon: const Icon(Icons.delete_outline_rounded, color: ManagerColors.red, size: 19),
                  onPressed: () => _confirmDeleteEvent(event),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ManagerColors.tealSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_note_rounded, size: 40, color: ManagerColors.teal),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Events Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ManagerColors.navyDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No events have been created under your assigned venues yet. Create your first tournament, match or training session now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: ManagerColors.secondaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create First Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ManagerColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
