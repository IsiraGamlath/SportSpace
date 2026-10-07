// lib/views/tertiary/tertiary_placeholder_view.dart
//
// Minimal placeholder screen used for Tertiary Stakeholder destinations
// that haven't been built yet (Events, Facilities, Notifications,
// Profile, or an event's detail page). This lets Home screen navigation
// be demonstrated/testable now without building unrelated screens.
// Swap it out for the real screen later — nothing else needs to change.

import 'package:flutter/material.dart';

class TertiaryPlaceholderView extends StatelessWidget {
  final String title;

  const TertiaryPlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF5F6F8),
        foregroundColor: const Color(0xFF0F2A44),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title screen coming soon',
          style: const TextStyle(fontSize: 14, color: Color(0xFF8A93A3)),
        ),
      ),
    );
  }
}