import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DateSelector extends StatelessWidget {
  final List<String> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onDateSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.tabSelectedNavy
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? null
                    : Border.all(
                        color: AppColors.chipBorder,
                        width: 1.2,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.tabSelectedNavy.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                dates[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
