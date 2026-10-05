import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';

class PendingPaymentPill extends StatelessWidget {
  const PendingPaymentPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: ManagerColors.orangeSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ManagerColors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Pending Payment',
            style: TextStyle(
              color: ManagerColors.orange,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
