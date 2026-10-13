import 'package:flutter/material.dart';

import '../../models/sport_event_model.dart';
import '../../services/api_service.dart';
import '../../services/app_services.dart';
import '../../theme/manager_colors.dart';

class ManagerCreateEventScreen extends StatefulWidget {
  final String? facilityName;
  final String? facilityId;
  final String? facilityLocation;
  final List<Map<String, dynamic>>? assignedFacilities;
  final NearbyEvent? eventToEdit;

  const ManagerCreateEventScreen({
    super.key,
    this.facilityName,
    this.facilityId,
    this.facilityLocation,
    this.assignedFacilities,
    this.eventToEdit,
  });

  @override
  State<ManagerCreateEventScreen> createState() => _ManagerCreateEventScreenState();
}

class _ManagerCreateEventScreenState extends State<ManagerCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController(text: '30');

  String _selectedSport = 'Badminton';
  String _selectedEventType = 'Tournament';
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);

  bool _isSubmitting = false;
  bool _isLoadingFacilities = false;
  List<Map<String, dynamic>> _assignedFacilities = [];
  late String _activeFacilityName;
  late String _activeFacilityId;
  late String _activeFacilityLocation;

  static const List<String> _sportsOptions = [
    'Badminton',
    'Football',
    'Basketball',
    'Tennis',
    'Cricket',
    'Squash',
    'Table Tennis',
    'Swimming',
    'Volleyball',
  ];

  static const List<String> _eventTypes = [
    'Tournament',
    'Friendly',
    'Training',
    'League',
    'Match',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    if (widget.eventToEdit != null) {
      final ev = widget.eventToEdit!;
      _titleController.text = ev.title;
      _descriptionController.text = ev.description;
      _capacityController.text = ev.capacity.toString();
      _selectedSport = _sportsOptions.contains(ev.sport) ? ev.sport : 'Badminton';
      _selectedEventType = _eventTypes.contains(ev.eventType) ? ev.eventType : 'Tournament';
      _selectedDate = ev.eventDate;
      _activeFacilityName = ev.facility.isNotEmpty ? ev.facility : 'My Sports Centre';
      _activeFacilityId = ev.facilityId.isNotEmpty ? ev.facilityId : 'fac_colombo_sports_hub';
      _activeFacilityLocation = ev.location.isNotEmpty ? ev.location : '$_activeFacilityName, Colombo';
    } else {
      _activeFacilityName = (widget.facilityName != null && widget.facilityName!.isNotEmpty)
          ? widget.facilityName!
          : 'My Sports Centre';
      _activeFacilityId = widget.facilityId ?? 'fac_colombo_sports_hub';
      _activeFacilityLocation = widget.facilityLocation ?? '$_activeFacilityName, Colombo';
    }

    if (widget.assignedFacilities != null && widget.assignedFacilities!.isNotEmpty) {
      _assignedFacilities = List<Map<String, dynamic>>.from(widget.assignedFacilities!);
    } else if (_activeFacilityName.isNotEmpty) {
      _assignedFacilities = [
        {
          'id': _activeFacilityId,
          'name': _activeFacilityName,
          'location': _activeFacilityLocation,
        }
      ];
    }

    _loadAssignedFacilities();
  }

  Future<void> _loadAssignedFacilities() async {
    if (_assignedFacilities.length > 1) return;
    setState(() => _isLoadingFacilities = true);
    try {
      final facilities = await ApiService.fetchManagerFacilities();
      if (facilities.isNotEmpty && mounted) {
        setState(() {
          _assignedFacilities = facilities;
          final exists = _assignedFacilities.any((f) {
            final id = f['id']?.toString() ?? f['_id']?.toString();
            return id == _activeFacilityId;
          });

          if (!exists && _assignedFacilities.isNotEmpty) {
            final first = _assignedFacilities.first;
            _activeFacilityId = first['id']?.toString() ?? first['_id']?.toString() ?? 'fac_1';
            _activeFacilityName = first['name']?.toString() ?? 'My Sports Centre';
            _activeFacilityLocation = first['location']?.toString() ?? '$_activeFacilityName, Colombo';
          }
          _isLoadingFacilities = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      if (_assignedFacilities.isEmpty) {
        _assignedFacilities = [
          {
            'id': _activeFacilityId,
            'name': _activeFacilityName,
            'location': _activeFacilityLocation,
          }
        ];
      }
      setState(() => _isLoadingFacilities = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatTimeRange() {
    return '${_formatTimeOfDay(_startTime)} – ${_formatTimeOfDay(_endTime)}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ManagerColors.navy,
              onPrimary: Colors.white,
              onSurface: ManagerColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ManagerColors.navy,
              onPrimary: Colors.white,
              onSurface: ManagerColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ManagerColors.navy,
              onPrimary: Colors.white,
              onSurface: ManagerColors.navyDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  String _resolveSportImage(String sport) {
    switch (sport.toLowerCase()) {
      case 'badminton':
        return 'assets/images/badminton.jpg';
      case 'football':
        return 'assets/images/football.jpg';
      case 'basketball':
        return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200&q=80';
      case 'tennis':
        return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=1200&q=80';
      case 'cricket':
        return 'https://images.unsplash.com/photo-1531415074868-83633dd5e439?w=1200&q=80';
      case 'swimming':
        return 'https://images.unsplash.com/photo-1530549387789-4c1017266635?w=1200&q=80';
      default:
        return 'assets/images/badminton.jpg';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'SP';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    if (capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid participant capacity greater than 0.'),
          backgroundColor: ManagerColors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final eventId = 'evt_${DateTime.now().millisecondsSinceEpoch}';
      final formattedDate = _formatDate(_selectedDate);
      final formattedTime = _formatTimeRange();

      if (widget.eventToEdit != null) {
        final updated = widget.eventToEdit!.copyWith(
          title: _titleController.text.trim(),
          sport: _selectedSport,
          date: formattedDate,
          time: formattedTime,
          eventDate: _selectedDate,
          location: _activeFacilityLocation,
          facility: _activeFacilityName,
          facilityId: _activeFacilityId,
          eventType: _selectedEventType,
          description: _descriptionController.text.trim(),
          capacity: capacity,
        );

        await appServices.eventRepository.updateEvent(updated);

        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Event "${updated.title}" updated successfully!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: ManagerColors.teal,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        }
        return;
      }

      final newEvent = NearbyEvent(
        id: eventId,
        title: _titleController.text.trim(),
        sport: _selectedSport,
        date: formattedDate,
        time: formattedTime,
        eventDate: _selectedDate,
        location: _activeFacilityLocation,
        facility: _activeFacilityName,
        facilityId: _activeFacilityId,
        eventType: _selectedEventType,
        status: 'Open',
        imageUrl: _resolveSportImage(_selectedSport),
        description: _descriptionController.text.trim(),
        organizerName: _activeFacilityName,
        organizerInitials: _getInitials(_activeFacilityName),
        capacity: capacity,
        participants: const [],
        participantCount: 0,
        timeline: [
          EventTimelineItem(time: _formatTimeOfDay(_startTime), label: 'Opening & Check-in'),
          EventTimelineItem(time: _formatTimeOfDay(_endTime), label: 'Wrap-up & Close'),
        ],
      );

      await appServices.eventRepository.createEvent(newEvent);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Event "${newEvent.title}" published under $_activeFacilityName!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: ManagerColors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish event: $e'),
            backgroundColor: ManagerColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          widget.eventToEdit != null ? 'Edit Event' : 'Create Event',
          style: const TextStyle(
            color: ManagerColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ASSIGNED FACILITY SELECTION (PRIVILEGE TO CHOOSE)
                _buildFieldLabel('Host Facility / Venue *'),
                const SizedBox(height: 2),
                const Text(
                  'Choose which of your assigned venues will host this event.',
                  style: TextStyle(
                    fontSize: 12,
                    color: ManagerColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                if (_isLoadingFacilities)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ManagerColors.border),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ManagerColors.teal),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Loading your assigned facilities...',
                          style: TextStyle(fontSize: 13, color: ManagerColors.secondaryText),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _assignedFacilities.any((f) => (f['id']?.toString() ?? f['_id']?.toString()) == _activeFacilityId)
                        ? _activeFacilityId
                        : (_assignedFacilities.isNotEmpty
                            ? (_assignedFacilities.first['id']?.toString() ?? _assignedFacilities.first['_id']?.toString())
                            : null),
                    isExpanded: true,
                    itemHeight: 56.0,
                    decoration: _buildInputDecoration(
                      hintText: 'Select Assigned Facility',
                      prefixIcon: Icons.stadium_rounded,
                    ),
                    items: _assignedFacilities.map((facility) {
                      final facId = facility['id']?.toString() ?? facility['_id']?.toString() ?? '';
                      final facName = facility['name']?.toString() ?? 'Facility';
                      final facLoc = facility['location']?.toString() ?? '';
                      return DropdownMenuItem<String>(
                        value: facId,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              facName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ManagerColors.navyDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (facLoc.isNotEmpty)
                              Text(
                                facLoc,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: ManagerColors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return _assignedFacilities.map((facility) {
                        final facName = facility['name']?.toString() ?? 'Facility';
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            facName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ManagerColors.navyDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (val) {
                      if (val != null) {
                        final chosen = _assignedFacilities.firstWhere(
                          (f) => (f['id']?.toString() ?? f['_id']?.toString()) == val,
                          orElse: () => <String, dynamic>{},
                        );
                        if (chosen.isNotEmpty) {
                          setState(() {
                            _activeFacilityId = val;
                            _activeFacilityName = chosen['name']?.toString() ?? _activeFacilityName;
                            _activeFacilityLocation = chosen['location']?.toString() ?? '$_activeFacilityName, Colombo';
                          });
                        }
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please choose an assigned venue';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 10),

                // Selected Assigned Facility Details Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ManagerColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ManagerColors.tealSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          color: ManagerColors.teal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ManagerColors.tealSoft,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'Selected Facility',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: ManagerColors.teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Only venues assigned to you',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ManagerColors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeFacilityName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: ManagerColors.navyDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _activeFacilityLocation,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: ManagerColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // 2. EVENT TITLE
                _buildFieldLabel('Event Name *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _buildInputDecoration(
                    hintText: 'e.g. Colombo Open Badminton Championship 2026',
                    prefixIcon: Icons.title_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the event name';
                    }
                    if (value.trim().length < 3) {
                      return 'Event name must be at least 3 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // 3. SPORT & CATEGORY
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Sport / Category *'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSport,
                            isExpanded: true,
                            decoration: _buildInputDecoration(
                              hintText: 'Select Sport',
                              prefixIcon: Icons.sports_tennis_rounded,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                              isDense: true,
                            ),
                            items: _sportsOptions.map((sport) {
                              return DropdownMenuItem(
                                value: sport,
                                child: Text(
                                  sport,
                                  style: const TextStyle(fontSize: 12.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSport = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Event Type *'),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedEventType,
                            isExpanded: true,
                            decoration: _buildInputDecoration(
                              hintText: 'Select Type',
                              prefixIcon: Icons.category_outlined,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                              isDense: true,
                            ),
                            items: _eventTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: const TextStyle(fontSize: 12.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedEventType = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 4. DATE SELECTION
                _buildFieldLabel('Event Date *'),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ManagerColors.border, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: ManagerColors.navy),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ManagerColors.navyDark,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ManagerColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 5. TIME RANGE
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Start Time *'),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickStartTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ManagerColors.border, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: ManagerColors.navy),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimeOfDay(_startTime),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: ManagerColors.navyDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('End Time *'),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickEndTime,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ManagerColors.border, width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_filled_rounded, size: 16, color: ManagerColors.navy),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimeOfDay(_endTime),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: ManagerColors.navyDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 6. CAPACITY / LIMIT
                _buildFieldLabel('Participant Capacity / Limit *'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. 30',
                          prefixIcon: Icons.group_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter capacity limit';
                          }
                          final numVal = int.tryParse(value.trim());
                          if (numVal == null || numVal <= 0) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCapacityAdjuster(
                      icon: Icons.remove,
                      onTap: () {
                        final cur = int.tryParse(_capacityController.text.trim()) ?? 30;
                        if (cur > 5) {
                          _capacityController.text = (cur - 5).toString();
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    _buildCapacityAdjuster(
                      icon: Icons.add,
                      onTap: () {
                        final cur = int.tryParse(_capacityController.text.trim()) ?? 30;
                        _capacityController.text = (cur + 5).toString();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 7. DESCRIPTION
                _buildFieldLabel('Event Description *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Provide details about registration, matches, equipment, rules, and who can participate...',
                    hintStyle: const TextStyle(color: ManagerColors.secondaryText, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ManagerColors.border, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ManagerColors.border, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: ManagerColors.navy, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide an event description';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // 8. SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ManagerColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.eventToEdit != null ? 'Saving Changes...' : 'Creating Event...',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.eventToEdit != null
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.eventToEdit != null ? 'Save Changes' : 'Publish Event',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: ManagerColors.navy,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    EdgeInsetsGeometry? contentPadding,
    bool isDense = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: ManagerColors.secondaryText, fontSize: 13),
      isDense: isDense,
      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Icon(prefixIcon, size: 16, color: ManagerColors.navy),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ManagerColors.border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ManagerColors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ManagerColors.navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ManagerColors.red, width: 1.2),
      ),
    );
  }

  Widget _buildCapacityAdjuster({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ManagerColors.border, width: 1.2),
        ),
        child: Icon(icon, color: ManagerColors.navy, size: 20),
      ),
    );
  }
}
