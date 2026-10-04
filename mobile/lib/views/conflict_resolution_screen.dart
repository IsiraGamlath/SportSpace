import 'package:flutter/material.dart';

import '../models/time_slot.dart';
import '../utils/app_colors.dart';
import '../widgets/conflict_alert_banner.dart';
import '../widgets/booked_slot_card.dart';
import '../widgets/alternative_times.dart';

class ConflictResolutionScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  const Text(
                    'Slot Unavailable',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const ConflictAlertBanner(
                title: 'This slot was just booked.',
                message: 'Someone else completed their booking for this time while '
                    'you were checking out. No charge has been made to you.',
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Your selection'),
              const SizedBox(height: 10),
              BookedSlotCard(
                timeRange: bookedSlot.durationRange,
                courtName: courtName,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Other available times'),
              const SizedBox(height: 12),
              Center(
                child: AlternativeTimes(
                  times: alternatives.map((e) => e.time).toList(),
                  onSelected: (time) {
                    final selectedSlot = alternatives.firstWhere((s) => s.time == time);
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Availability refreshed'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Availability'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    foregroundColor: AppColors.darkNavy,
                    side: const BorderSide(color: AppColors.chipBorder),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
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
