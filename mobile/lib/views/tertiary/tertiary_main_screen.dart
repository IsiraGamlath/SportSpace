import 'package:flutter/material.dart';

import '../../widgets/tertiary/nav_bar.dart';
import 'events_view.dart';
import 'facilities_view.dart';
import 'home_view.dart';
import 'notifications_view.dart';
import 'profile_view.dart';

class TertiaryMainScreen extends StatefulWidget {
  const TertiaryMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  static TertiaryMainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<TertiaryMainScreenState>();
  }

  @override
  State<TertiaryMainScreen> createState() => TertiaryMainScreenState();
}

class TertiaryMainScreenState extends State<TertiaryMainScreen> {
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
          TertiaryHomeView(showBottomNav: false),
          EventsView(showBottomNav: false),
          FacilitiesView(showBottomNav: false),
          NotificationsView(showBottomNav: false),
          ProfileView(showBottomNav: false),
        ],
      ),
      bottomNavigationBar: TertiaryNavBar(
        currentIndex: _currentIndex,
        onItemSelected: setTab,
      ),
    );
  }
}
