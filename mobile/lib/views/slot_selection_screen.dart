import 'package:flutter/material.dart';

import '../models/time_slot.dart';
import '../utils/app_colors.dart';
import '../widgets/court_info_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/slot_grid.dart';
import '../widgets/slot_legend.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';
import 'checkout_screen.dart';

class SlotSelectionScreen extends StatefulWidget {
  final String? rescheduleBookingId;

  const SlotSelectionScreen({super.key, this.rescheduleBookingId});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  final List<String> _dates = const [
    'Today',
    'Tomorrow',
    'Wed 23',
    'Thu 24',
    'Fri 25',
    'Sat 26',
  ];

  int _selectedDateIndex = 1; // Default to 'Tomorrow' as shown in the UI

  late List<TimeSlot> _slots = [];
  bool _isLoading = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  Future<void> _fetchSlots() async {
    setState(() => _isLoading = true);
    try {
      final fetchedSlots = await ApiService.fetchSlots(date: _dates[_selectedDateIndex]);
      setState(() {
        _slots = fetchedSlots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading slots: $e')),
      );
    }
  }

  // Old mock initialize removed

  TimeSlot? get _selectedSlot {
    try {
      return _slots.firstWhere((s) => s.status == SlotStatus.selected);
    } catch (_) {
      return null;
    }
  }



  void _handleSlotTap(TimeSlot tappedSlot) {
    if (tappedSlot.status == SlotStatus.booked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tappedSlot.time} is already booked. Please choose an available slot.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }


    // Standard slot selection
    setState(() {
      _slots = _slots.map((s) {
        if (s.id == tappedSlot.id) {
          return s.copyWith(status: SlotStatus.selected);
        } else if (s.status == SlotStatus.selected) {
          return s.copyWith(status: SlotStatus.available);
        }
        return s;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSlot = _selectedSlot;
    final selectedDate = _dates[_selectedDateIndex];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderLight.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        customBorder: const CircleBorder(),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Select a Slot',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Court Info Card
                    const CourtInfoCard(
                      courtName: 'Badminton Court 1',
                      locationAndSport: 'Colombo Sports Centre · Badminton',
                      tag: 'Court',
                    ),
                    const SizedBox(height: 18),

                    // Date Selection Chips
                    DateSelector(
                      dates: _dates,
                      selectedIndex: _selectedDateIndex,
                      onDateSelected: (index) {
                        if (index != _selectedDateIndex) {
                          setState(() {
                            _selectedDateIndex = index;
                            _isLoading = true;
                          });
                          _fetchSlots();
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Availability Legend
                    const SlotLegend(),
                    const SizedBox(height: 24),

                    // Section Title
                    Text(
                      '$selectedDate · Available Times',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Slots Grid
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      SlotGrid(slots: _slots, onSlotTapped: _handleSlotTap),
                    const SizedBox(height: 18),
                    const SizedBox(height: 120), // Bottom bar clearance
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Booking Summary
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeSlot != null
                          ? activeSlot.durationRange
                          : 'No slot selected',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeSlot != null
                          ? 'LKR ${activeSlot.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
                          : 'LKR 0',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (activeSlot != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.availableBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.availableText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Selected',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.availableText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (activeSlot != null && !_isBooking)
                    ? () async {
                        if (widget.rescheduleBookingId != null) {
                          setState(() => _isBooking = true);
                          try {
                            await ApiService.rescheduleBooking(widget.rescheduleBookingId!, activeSlot.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking rescheduled successfully!'), backgroundColor: AppColors.availableText),
                              );
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isBooking = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to reschedule: $e'), backgroundColor: AppColors.bookedText),
                              );
                            }
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                slot: activeSlot,
                                date: _dates[_selectedDateIndex],
                                alternatives: _slots
                                    .where((s) => s.status == SlotStatus.available && s.id != activeSlot.id)
                                    .toList(),
                              ),
                            ),
                          ).then((_) {
                            if (mounted) _fetchSlots();
                          });
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  disabledBackgroundColor: AppColors.textMuted.withValues(
                    alpha: 0.3,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isBooking
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : Text(
                        widget.rescheduleBookingId != null ? 'Confirm Reschedule' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
