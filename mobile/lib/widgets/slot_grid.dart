import 'package:flutter/material.dart';
import '../models/time_slot.dart';
import '../utils/app_colors.dart';

class SlotGrid extends StatelessWidget {
  final List<TimeSlot> slots;
  final ValueChanged<TimeSlot> onSlotTapped;

  const SlotGrid({
    super.key,
    required this.slots,
    required this.onSlotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 14,
        childAspectRatio: 2.65,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        return _buildSlotCard(slot);
      },
    );
  }

  Widget _buildSlotCard(TimeSlot slot) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (slot.status) {
      case SlotStatus.available:
        bgColor = AppColors.availableBg;
        textColor = AppColors.availableText;
        border = Border.all(
          color: AppColors.availableBorder,
          width: 1.5,
        );
        break;
      case SlotStatus.selected:
        bgColor = AppColors.selectedBg;
        textColor = AppColors.selectedText;
        border = Border.all(
          color: AppColors.selectedBorder,
          width: 1.5,
        );
        break;
      case SlotStatus.booked:
        bgColor = AppColors.bookedBg;
        textColor = AppColors.bookedText;
        border = Border.all(
          color: AppColors.bookedBorder,
          width: 1.0,
        );
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSlotTapped(slot),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
          ),
          alignment: Alignment.center,
          child: Text(
            slot.time,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
