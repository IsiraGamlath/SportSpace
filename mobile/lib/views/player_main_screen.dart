import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'account_profile_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'player_notifications_view.dart';

class PlayerMainScreen extends StatefulWidget {
  const PlayerMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  static PlayerMainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<PlayerMainScreenState>();
  }

  @override
  State<PlayerMainScreen> createState() => PlayerMainScreenState();
}

class PlayerMainScreenState extends State<PlayerMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(showBottomNav: false),
          ExploreScreen(showBottomNav: false),
          MyBookingsScreen(showBottomNav: false),
          PlayerNotificationsView(showBottomNav: false),
          UserProfileScreen(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: setTab,
      ),
    );
  }
}
