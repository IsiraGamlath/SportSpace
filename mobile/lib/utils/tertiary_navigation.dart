
import 'package:flutter/material.dart';

import '../views/tertiary/home_view.dart';
import '../views/tertiary/events_view.dart';
import '../views/tertiary/facilities_view.dart';
import '../views/tertiary/notifications_view.dart';
import '../views/tertiary/profile_view.dart';

const List<String> kTertiaryTabLabels = [
  'Home',
  'Events',
  'Facilities',
  'Notifications',
  'Profile',
];

void handleTertiaryNavTap({
  required BuildContext context,
  required int tappedIndex,
  required int currentIndex,
}) {
  if (tappedIndex == currentIndex) return;

  switch (tappedIndex) {
    case 0:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TertiaryHomeView()),
        (route) => false,
      );
      break;
    case 1:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EventsView()),
        (route) => false,
      );
      break;
    case 2:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FacilitiesView()),
        (route) => false,
      );
      break;
    case 3:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NotificationsView()),
        (route) => false,
      );
      break;
    case 4:
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfileView()),
        (route) => false,
      );
      break;
  }
}