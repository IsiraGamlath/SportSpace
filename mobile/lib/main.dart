// lib/main.dart
//
// Minimal entry point so the Tertiary Stakeholder Home screen can be
// built/run in isolation for testing.
//
// IMPORTANT: If your real main.dart already sets up Player/Manager
// entry points, role selection, or app-wide theming, don't just
// overwrite it with this — merge the `home:` / routing logic in below
// instead, so Player/Manager setup stays untouched.

import 'package:flutter/material.dart';

import 'views/tertiary/home_view.dart';

void main() {
  runApp(const SportSpaceApp());
}

class SportSpaceApp extends StatelessWidget {
  const SportSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
      ),
      // Temporary: launches straight into the Tertiary Stakeholder
      // Home screen for development/testing. Replace `home:` with
      // your real entry point (login, role selection, etc.) once
      // that flow exists — this doesn't touch Player/Manager code.
      home: const TertiaryHomeView(),
    );
  }
}