import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AlternativeTimes extends StatelessWidget {
  const AlternativeTimes({
    super.key,
    required this.times,
    required this.onSelected,
  });

  final List<String> times;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final t in times) _TimeChip(label: t, onTap: () => onSelected(t)),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: AppColors.available),
    );
    return Material(
      color: AppColors.availableBg,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.available,
            ),
          ),
        ),
      ),
    );
  }
}
