import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/manager_bottom_nav.dart';
import 'manager_booking_details_screen.dart';
import 'manager_dashboard_screen.dart';
import 'manager_maintenance_screen.dart';
import 'manager_profile_screen.dart';
import 'manager_schedule_screen.dart';

class ManagerMainScreen extends StatefulWidget {
  const ManagerMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<ManagerMainScreen> createState() => _ManagerMainScreenState();
}

class _ManagerMainScreenState extends State<ManagerMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: ManagerColors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              ManagerDashboardScreen(onNavigateTab: _onTabSelected),
              const ManagerScheduleScreen(),
              const ManagerBookingDetailsScreen(),
              const ManagerMaintenanceScreen(),
              const ManagerProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: ManagerBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
        ),
      ),
    );
  }
}
