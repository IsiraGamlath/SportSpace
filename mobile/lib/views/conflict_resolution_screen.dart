import 'package:flutter/material.dart';

import '../models/time_slot.dart';
import '../utils/app_colors.dart';
import '../widgets/conflict_alert_banner.dart';
import '../widgets/booked_slot_card.dart';
import '../widgets/alternative_times.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';

class ConflictResolutionScreen extends StatefulWidget {
  final TimeSlot bookedSlot;
  final String courtName;
  final List<TimeSlot> alternatives;
  final String date;

  const ConflictResolutionScreen({
    super.key,
    required this.bookedSlot,
    required this.courtName,
    required this.alternatives,
    required this.date,
  });

  @override
  State<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  bool _isLoading = true;
  bool _isConflict = false;

  @override
  void initState() {
    super.initState();
    _processBooking();
  }

  Future<void> _processBooking() async {
    // If it's the hardcoded conflict demo trigger, just simulate conflict
    if (widget.bookedSlot.isConflictTrigger) {
      await Future.delayed(const Duration(milliseconds: 800)); // fake delay
      if (mounted) {
        setState(() {
          _isConflict = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await ApiService.bookSlot(widget.bookedSlot.id);
      if (mounted) {
        setState(() {
          _isConflict = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConflict = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _BackButton(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 16),
                        Text(
                          _isConflict ? 'Slot Unavailable' : 'Checkout',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isConflict)
                      const ConflictAlertBanner(
                        title: 'This slot was just booked.',
                        message: 'Someone else completed their booking for this time while '
                            'you were selecting your slot. No charge has been made to you.',
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.availableBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.availableBorder.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline, color: AppColors.availableText, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Slot is available!',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.availableText,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your selected time is secured. Proceed to finalize booking.',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Your selection'),
                    const SizedBox(height: 10),
                    _isConflict
                        ? BookedSlotCard(
                            timeRange: widget.bookedSlot.durationRange,
                            courtName: widget.courtName,
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.bookedSlot.durationRange,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkNavy,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.courtName,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.availableBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Available',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.availableText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 24),
                    if (_isConflict) ...[
                      const _SectionTitle('Other available times'),
                      const SizedBox(height: 12),
                      Center(
                        child: AlternativeTimes(
                          times: widget.alternatives.map((e) => e.time).toList(),
                          onSelected: (time) {
                            final selectedSlot = widget.alternatives.firstWhere((s) => s.time == time);
                            Navigator.pop(context, selectedSlot);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Choose Another Slot',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingConfirmationScreen(
                                  slot: widget.bookedSlot,
                                  date: widget.date,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.darkNavy,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      shape: const CircleBorder(side: BorderSide(color: AppColors.borderLight)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
