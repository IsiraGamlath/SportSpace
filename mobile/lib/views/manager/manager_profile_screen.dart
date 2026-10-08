import 'package:flutter/material.dart';

import '../account_profile_screen.dart';

class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key, this.onOpenBookings});

  final VoidCallback? onOpenBookings;

  @override
  Widget build(BuildContext context) {
    return AccountProfileContent(
      managerPortal: true,
      onOpenManagerBookings: onOpenBookings,
    );
  }
}
