import 'package:flutter/material.dart';

import '../account_profile_screen.dart';

class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key, this.onOpenBookings});

  final VoidCallback? onOpenBookings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: AccountProfileContent(
          managerPortal: true,
          onOpenManagerBookings: onOpenBookings,
        ),
      ),
    );
  }
}
