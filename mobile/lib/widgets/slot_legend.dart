import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SlotLegend extends StatelessWidget {
  const SlotLegend({super.key});

  Widget _buildLegendItem({
    required Widget indicator,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildLegendItem(
          indicator: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.availableBg,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: AppColors.availableBorder,
                width: 1.4,
              ),
            ),
          ),
          label: 'Available',
        ),
        const SizedBox(width: 18),
        _buildLegendItem(
          indicator: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.selectedBg,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          label: 'Selected',
        ),
        const SizedBox(width: 18),
        _buildLegendItem(
          indicator: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.bookedBg,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: AppColors.bookedText,
                width: 1.4,
              ),
            ),
          ),
          label: 'Booked',
        ),
      ],
    );
  }
}
