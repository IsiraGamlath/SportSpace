import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/manager_colors.dart';
import '../../widgets/manager/schedule_card.dart';
import 'manager_booking_details_screen.dart';
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
  bool _daySelected = true;
  int _selectedCourt = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];

  final List<String> _courts = [
    'All Courts',
    'Badminton Court 1',
    'Badminton Court 2',
    'Tennis Court 1',
    'Basketball Court',
  ];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    try {
      final courtFilter = _selectedCourt == 0 ? null : _courts[_selectedCourt];
      final dateFilter = _daySelected ? 'Tomorrow' : 'Today';

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

  void _openBookingDetails() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManagerBookingDetailsScreen(),
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

  void _showAddSlotModal() {
    if (!widget.isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pending Approval: You cannot add or manage facility slots until an admin verifies your account.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedCourtName = _courts[1];
    TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    final priceController = TextEditingController(text: '2500');
    final reasonController = TextEditingController(text: 'Routine maintenance window');

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
                    'Facility Court',
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
                        value: selectedCourtName,
                        items: _courts
                            .where((c) => c != 'All Courts')
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedCourtName = val);
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
                            try {
                              await ApiService.createSlot({
                                'courtName': selectedCourtName,
                                'time': startFormatted,
                                'durationRange': durationRangeStr,
                                'price': priceVal,
                                'date': _daySelected ? 'Tomorrow' : 'Today',
                                'status': 'available',
                              });
                              _loadSlots();
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added slot for $selectedCourtName ($durationRangeStr)'),
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
                            try {
                              await ApiService.createSlot({
                                'courtName': selectedCourtName,
                                'time': startFormatted,
                                'durationRange': durationRangeStr,
                                'price': priceVal,
                                'date': _daySelected ? 'Tomorrow' : 'Today',
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
                    const SizedBox(height: 18),
                    _buildDateRow(),
                    const SizedBox(height: 14),
                    _buildCourtFilters(),
                    const SizedBox(height: 18),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(color: ManagerColors.navy),
                        ),
                      )
                    else if (_slots.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text(
                          'No facility slots found for the selected filter.',
                          style: TextStyle(
                            color: ManagerColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
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
                                ? _openBookingDetails
                                : () => _showSlotActionModal(slot),
                          );
                        },
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _showAddSlotModal,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ManagerColors.navy,
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(
                            color: ManagerColors.border,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          '+ Add Schedule / Block Slot',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF1F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Tomorrow',
              selected: _daySelected,
              onTap: () {
                setState(() => _daySelected = true);
                _loadSlots();
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegmentButton(
              label: 'Today',
              selected: !_daySelected,
              onTap: () {
                setState(() => _daySelected = false);
                _loadSlots();
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
            _daySelected ? 'Tomorrow Schedule' : 'Today Schedule',
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : ManagerColors.navyDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
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
