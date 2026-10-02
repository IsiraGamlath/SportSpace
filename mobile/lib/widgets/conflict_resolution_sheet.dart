import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ConflictResolutionSheet extends StatelessWidget {
  final VoidCallback onSelectAlternative;
  final VoidCallback onDismiss;

  const ConflictResolutionSheet({
    super.key,
    required this.onSelectAlternative,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSelectAlternative,
    required VoidCallback onDismiss,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConflictResolutionSheet(
        onSelectAlternative: () {
          Navigator.pop(context);
          onSelectAlternative();
        },
        onDismiss: () {
          Navigator.pop(context);
          onDismiss();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Conflict alert icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.bookedBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.bookedBorder,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.sync_problem_rounded,
              color: AppColors.bookedText,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Slot No Longer Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          const Text(
            'The 7:00 PM slot was just booked by another player a few seconds ago. To prevent double-booking, SportSpace has refreshed the court schedule.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Recommended alternative card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.availableBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.availableBorder.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.availableText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended Alternative',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.availableText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '7:30 PM (Tomorrow)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.availableBorder,
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.availableText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSelectAlternative,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Select 7:30 PM Instead',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text(
                'Dismiss & Choose Another Slot',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
