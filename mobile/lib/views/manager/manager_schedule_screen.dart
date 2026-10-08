import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';
import '../../widgets/manager/schedule_card.dart';
import 'manager_booking_details_screen.dart';
import 'manager_facilities_screen.dart';
import 'manager_notifications_screen.dart';

class ManagerScheduleScreen extends StatefulWidget {
  const ManagerScheduleScreen({
    super.key,
    this.isApproved = false,
  });

  final bool isApproved;

  @override
  State<ManagerScheduleScreen> createState() => _ManagerScheduleScreenState();
}

class _ManagerScheduleScreenState extends State<ManagerScheduleScreen> {
  bool _isWeekView = false;
  int _selectedDayIndex = 0;
  int _selectedCourt = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];

  final List<String> _days = [
    'Today',
    'Tomorrow',
    'Wed 23',
    'Thu 24',
    'Fri 25',
    'Sat 26',
    'Sun 27',
  ];

  List<String> _courts = [
    'All Courts',
    'Badminton Court 1',
    'Badminton Court 2',
    'Tennis Court 1',
    'Basketball Court',
  ];

  List<Map<String, dynamic>> _facilityList = [];

  @override
  void initState() {
    super.initState();
    _loadFacilitiesAndSlots();
  }

  Future<void> _loadFacilitiesAndSlots() async {
    try {
      final facilities = await ApiService.fetchFacilities();
      if (mounted && facilities.isNotEmpty) {
        setState(() {
          _facilityList = facilities;
          final names = facilities
              .map((f) => f['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          _courts = ['All Courts', ...names];
          if (_selectedCourt >= _courts.length) {
            _selectedCourt = 0;
          }
        });
      }
    } catch (_) {}
    await _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    try {
      final courtFilter = _selectedCourt == 0 ? null : _courts[_selectedCourt];
      final dateFilter = _isWeekView ? null : _days[_selectedDayIndex];

      final slots = await ApiService.fetchManagerSlots(
        date: dateFilter,
        courtName: courtFilter,
      );

      if (mounted) {
        setState(() {
          _slots = slots;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openBookingDetails([String? bookingId]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManagerBookingDetailsScreen(
          bookingId: bookingId ?? 'SS-20481',
        ),
      ),
    ).then((_) => _loadSlots());
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerNotificationsScreen(),
      ),
    );
  }

  void _showAddSlotModal({String? initialDate}) {
    final availableCourts = _courts.where((c) => c != 'All Courts').toList();
    String selectedCourtName =
        availableCourts.isNotEmpty ? availableCourts.first : 'Badminton Court 1';

    final initialFacility = _facilityList.firstWhere(
      (f) => f['name'] == selectedCourtName,
      orElse: () => <String, dynamic>{},
    );
    final initialRate = initialFacility['hourlyRate']?.toString() ?? '2500';

    String selectedDate = initialDate ?? _days[_selectedDayIndex];
    TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    final priceController = TextEditingController(text: initialRate);
    final reasonController =
        TextEditingController(text: 'Routine maintenance window');

    String formatTimeOfDay(TimeOfDay tod) {
      final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final minute = tod.minute.toString().padLeft(2, '0');
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final startFormatted = formatTimeOfDay(startTime);
            final endFormatted = formatTimeOfDay(endTime);
            final durationRangeStr = '$startFormatted – $endFormatted';

            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                22,
                22,
                MediaQuery.of(context).viewInsets.bottom + 26,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Slot or Block Schedule',
                        style: TextStyle(
                          color: ManagerColors.navyDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Schedule Date',
                    style: TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ManagerColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedDate,
                        items: _days
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedDate = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Facility Court',
                        style: TextStyle(
                          color: ManagerColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ManagerFacilitiesScreen(),
                            ),
                          ).then((_) => _loadFacilitiesAndSlots());
                        },
                        child: const Text(
                          '+ Manage Facilities',
                          style: TextStyle(
                            color: ManagerColors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ManagerColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: availableCourts.contains(selectedCourtName)
                            ? selectedCourtName
                            : (availableCourts.isNotEmpty
                                ? availableCourts.first
                                : null),
                        items: availableCourts
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedCourtName = val;
                              final matchingFacility = _facilityList.firstWhere(
                                (f) => f['name'] == val,
                                orElse: () => <String, dynamic>{},
                              );
                              if (matchingFacility.isNotEmpty &&
                                  matchingFacility['hourlyRate'] != null) {
                                priceController.text =
                                    matchingFacility['hourlyRate'].toString();
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'Define Time Window',
                    style: TextStyle(
                      color: ManagerColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Start Time Picker Card
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setModalState(() => startTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ManagerColors.border),
                              color: const Color(0xFFF8FAFC),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    color: ManagerColors.secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: ManagerColors.navy,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      startFormatted,
                                      style: const TextStyle(
                                        color: ManagerColors.navyDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // End Time Picker Card
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setModalState(() => endTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ManagerColors.border),
                              color: const Color(0xFFF8FAFC),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(
                                    color: ManagerColors.secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: ManagerColors.navy,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      endFormatted,
                                      style: const TextStyle(
                                        color: ManagerColors.navyDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Window: $durationRangeStr',
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price (LKR)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Block Reason (if blocking slot)',
                      hintText: 'e.g. Surface cleaning or maintenance',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final priceVal = double.tryParse(priceController.text.trim()) ?? 2500.0;
                            final matchingFacility = _facilityList.firstWhere(
                              (f) => f['name'] == selectedCourtName,
                              orElse: () => <String, dynamic>{},
                            );
                            final fType = matchingFacility['type']?.toString() ?? 'Badminton';

                            try {
                              await ApiService.createSlot({
                                'courtName': selectedCourtName,
                                'facilityType': fType,
                                'time': startFormatted,
                                'durationRange': durationRangeStr,
                                'price': priceVal,
                                'date': selectedDate,
                                'status': 'available',
                              });
                              _loadSlots();
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added slot for $selectedCourtName on $selectedDate ($durationRangeStr)'),
                                    backgroundColor: ManagerColors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Error adding slot: $e')),
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('Add Slot (Available)', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final priceVal = double.tryParse(priceController.text.trim()) ?? 2500.0;
                            final matchingFacility = _facilityList.firstWhere(
                              (f) => f['name'] == selectedCourtName,
                              orElse: () => <String, dynamic>{},
                            );
                            final fType = matchingFacility['type']?.toString() ?? 'Badminton';

                            try {
                              await ApiService.createSlot({
                                'courtName': selectedCourtName,
                                'facilityType': fType,
                                'time': startFormatted,
                                'durationRange': durationRangeStr,
                                'price': priceVal,
                                'date': selectedDate,
                                'status': 'blocked',
                                'blockedReason': reasonController.text.trim().isNotEmpty
                                    ? reasonController.text.trim()
                                    : 'Blocked by Manager',
                              });
                              _loadSlots();
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Blocked slot for $selectedCourtName ($durationRangeStr)'),
                                    backgroundColor: ManagerColors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Error blocking slot: $e')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ManagerColors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text('Block Slot', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSlotActionModal(Map<String, dynamic> slot) {
    if (!widget.isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pending Approval: You cannot manage slots until an admin verifies your account.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final slotId = slot['id'] ?? slot['_id'] ?? '';
    final courtName = slot['courtName'] ?? 'Court';
    final time = slot['time'] ?? '';
    final status = slot['status'] ?? 'available';
    final isBlocked = status == 'blocked';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$courtName — $time',
                style: const TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Current Status: ${status.toString().toUpperCase()}',
                style: const TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          await ApiService.toggleBlockSlot(
                            slotId,
                            blocked: !isBlocked,
                            reason: isBlocked ? null : 'Blocked by Manager',
                          );
                          _loadSlots();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isBlocked
                                      ? 'Slot unblocked and made Available'
                                      : 'Slot marked as Blocked',
                                ),
                                backgroundColor: isBlocked
                                    ? ManagerColors.green
                                    : ManagerColors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        isBlocked ? 'Unblock (Make Available)' : 'Block Slot',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await ApiService.deleteSlot(slotId);
                        _loadSlots();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Slot deleted')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete failed: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: ManagerColors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  ScheduleCardStatus _resolveStatus(String? status) {
    switch (status) {
      case 'booked':
        return ScheduleCardStatus.booked;
      case 'available':
        return ScheduleCardStatus.available;
      case 'pending':
        return ScheduleCardStatus.pending;
      case 'blocked':
        return ScheduleCardStatus.blocked;
      default:
        return ScheduleCardStatus.available;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: RefreshIndicator(
              onRefresh: _loadSlots,
              color: ManagerColors.navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDayWeekSwitch(),
                    const SizedBox(height: 14),

                    // Top Action Bar: Create Schedule & Facilities
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddSlotModal(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ManagerColors.navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                            label: const Text(
                              '+ Add Schedule / Slot',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ManagerFacilitiesScreen(),
                              ),
                            ).then((_) => _loadFacilitiesAndSlots());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ManagerColors.navy,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: ManagerColors.border),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.stadium_outlined, size: 18, color: ManagerColors.teal),
                          label: const Text(
                            'Facilities',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!_isWeekView) ...[
                      _buildDaySelector(),
                      const SizedBox(height: 14),
                      _buildDateRow(),
                      const SizedBox(height: 14),
                      _buildCourtFilters(),
                      const SizedBox(height: 18),
                      _buildDayViewBody(),
                    ] else ...[
                      _buildCourtFilters(),
                      const SizedBox(height: 16),
                      _buildWeekSummary(_slots),
                      const SizedBox(height: 18),
                      _buildWeekViewBody(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDayIndex;
          final dayName = _days[index];

          return InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: () {
              setState(() => _selectedDayIndex = index);
              _loadSlots();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? ManagerColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isSelected ? ManagerColors.navy : ManagerColors.chipBorder,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: ManagerColors.navy.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                dayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : ManagerColors.navyDark,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayViewBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: CircularProgressIndicator(color: ManagerColors.navy),
        ),
      );
    }

    if (_slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Text(
          'No facility slots found for ${_days[_selectedDayIndex]}.',
          style: const TextStyle(
            color: ManagerColors.secondaryText,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _slots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slot = _slots[index];
        final time = slot['time'] as String? ?? '5:00 PM';
        final courtName = slot['courtName'] as String? ?? 'Court';
        final statusStr = slot['status'] as String? ?? 'available';
        final blockedReason = slot['blockedReason'] as String?;

        if (statusStr == 'blocked') {
          return _BlockedScheduleCard(
            time: time,
            title: '$courtName — ${blockedReason ?? "Under Maintenance"}',
            onTap: () => _showSlotActionModal(slot),
          );
        }

        return ScheduleCard(
          time: time,
          title: courtName,
          status: _resolveStatus(statusStr),
          onTap: statusStr == 'booked'
              ? () => _openBookingDetails(slot['bookingId'] as String?)
              : () => _showSlotActionModal(slot),
        );
      },
    );
  }

  Widget _buildWeekSummary(List<Map<String, dynamic>> slots) {
    final total = slots.length;
    final available = slots.where((s) => s['status'] == 'available').length;
    final booked = slots.where((s) => s['status'] == 'booked').length;
    final blocked = slots.where((s) => s['status'] == 'blocked').length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ManagerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 18, color: ManagerColors.navy),
              const SizedBox(width: 8),
              const Text(
                '7-Day Weekly Summary',
                style: TextStyle(
                  color: ManagerColors.navyDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$total total slots',
                style: const TextStyle(
                  color: ManagerColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatBadge('Available', available, ManagerColors.green, const Color(0xFFE8F5E9)),
              const SizedBox(width: 8),
              _buildStatBadge('Booked', booked, ManagerColors.blue, const Color(0xFFE3F2FD)),
              const SizedBox(width: 8),
              _buildStatBadge('Blocked', blocked, ManagerColors.red, const Color(0xFFFFEBEE)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekViewBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: CircularProgressIndicator(color: ManagerColors.navy),
        ),
      );
    }

    // Group slots by day
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final day in _days) {
      grouped[day] = [];
    }
    for (final slot in _slots) {
      final slotDate = (slot['date'] as String?) ?? 'Tomorrow';
      grouped.putIfAbsent(slotDate, () => []).add(slot);
    }

    return Column(
      children: [
        for (final day in _days)
          _buildWeekDayCard(day, grouped[day] ?? []),
      ],
    );
  }

  Widget _buildWeekDayCard(String dayName, List<Map<String, dynamic>> daySlots) {
    final availCount = daySlots.where((s) => s['status'] == 'available').length;
    final bookedCount = daySlots.where((s) => s['status'] == 'booked').length;
    final blockedCount = daySlots.where((s) => s['status'] == 'blocked').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ManagerColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header Card
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () {
              final idx = _days.indexOf(dayName);
              if (idx != -1) {
                setState(() {
                  _isWeekView = false;
                  _selectedDayIndex = idx;
                });
                _loadSlots();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: ManagerColors.border.withValues(alpha: 0.6))),
              ),
              child: Row(
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      color: ManagerColors.navyDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: ManagerColors.navy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${daySlots.length} slots',
                      style: const TextStyle(
                        color: ManagerColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (availCount > 0)
                    Text(
                      '$availCount avail  ',
                      style: const TextStyle(
                        color: ManagerColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (bookedCount > 0)
                    Text(
                      '$bookedCount booked  ',
                      style: const TextStyle(
                        color: ManagerColors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (blockedCount > 0)
                    Text(
                      '$blockedCount blocked  ',
                      style: const TextStyle(
                        color: ManagerColors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: ManagerColors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
          // Day Content
          if (daySlots.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'No slots scheduled',
                    style: TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddSlotModal(initialDate: dayName),
                    icon: const Icon(Icons.add, size: 15, color: ManagerColors.navy),
                    label: const Text(
                      'Add Slot',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ManagerColors.navy,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...daySlots.map((slot) {
                    final time = slot['time'] as String? ?? '5:00 PM';
                    final courtName = slot['courtName'] as String? ?? 'Court';
                    final statusStr = slot['status'] as String? ?? 'available';
                    final blockedReason = slot['blockedReason'] as String?;

                    if (statusStr == 'blocked') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _BlockedScheduleCard(
                          time: time,
                          title: '$courtName — ${blockedReason ?? "Under Maintenance"}',
                          onTap: () => _showSlotActionModal(slot),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ScheduleCard(
                        time: time,
                        title: courtName,
                        status: _resolveStatus(statusStr),
                        onTap: statusStr == 'booked'
                            ? () => _openBookingDetails(slot['bookingId'] as String?)
                            : () => _showSlotActionModal(slot),
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Real-time Schedule',
          style: TextStyle(
            color: ManagerColors.navyDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: _openNotifications,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 21,
              color: ManagerColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayWeekSwitch() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Day View',
              icon: Icons.view_day_rounded,
              selected: !_isWeekView,
              onTap: () {
                if (_isWeekView) {
                  setState(() => _isWeekView = false);
                  _loadSlots();
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegmentButton(
              label: 'Week View',
              icon: Icons.calendar_view_week_rounded,
              selected: _isWeekView,
              onTap: () {
                if (!_isWeekView) {
                  setState(() => _isWeekView = true);
                  _loadSlots();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${_days[_selectedDayIndex]} Schedule',
            style: const TextStyle(
              color: ManagerColors.navyDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: ManagerColors.border),
          ),
          child: IconButton(
            onPressed: _loadSlots,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 19,
              color: ManagerColors.navy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourtFilters() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _courts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedCourt;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() => _selectedCourt = index);
              _loadSlots();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? ManagerColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? ManagerColors.navy : ManagerColors.chipBorder,
                ),
              ),
              child: Text(
                _courts[index],
                style: TextStyle(
                  color: selected ? Colors.white : ManagerColors.navyDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ManagerColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : ManagerColors.navyDark,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : ManagerColors.navyDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedScheduleCard extends StatelessWidget {
  const _BlockedScheduleCard({
    required this.time,
    required this.title,
    this.onTap,
  });

  final String time;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFCED8E1),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: ManagerColors.secondaryText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ManagerColors.blockedSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Blocked',
                style: TextStyle(
                  color: ManagerColors.blockedText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
