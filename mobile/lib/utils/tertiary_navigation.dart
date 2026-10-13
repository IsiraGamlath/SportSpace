import 'package:flutter/material.dart';

import '../views/tertiary/tertiary_main_screen.dart';

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

  final parent = TertiaryMainScreen.of(context);
  if (parent != null) {
    parent.setTab(tappedIndex);
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          TertiaryMainScreen(initialIndex: tappedIndex),
      transitionDuration: Duration.zero,
    ),
    (route) => false,
  );
}