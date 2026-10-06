import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF7F9FA);
  static const Color cardBackground = Colors.white;

  // Primary brand & selection colors
  static const Color primaryTeal = Color(0xFF247BA0);
  static const Color darkNavy = Color(0xFF163A5F);
  static const Color tabSelectedNavy = Color(0xFF163A5F);

  // Status: Available (Green)
  static const Color available = Color(0xFF22A06B);
  static const Color availableBg = Color(0xFFEDF7F2); // verify in Figma
  static const Color availableBorder = Color(0xFF22A06B);
  static const Color availableText = Color(0xFF22A06B);

  // Status: Selected (Teal)
  static const Color selectedBg = Color(0xFF247BA0);
  static const Color selectedBorder = Color(0xFF247BA0);
  static const Color selectedText = Colors.white;

  // Status: Booked (Pale Pink / Red)
  static const Color bookedBg = Color(0xFFFDF0EF); // verify in Figma
  static const Color bookedBorder = Color(0xFFF0D3D3);
  static const Color bookedText = Color(0xFFD64545);
  static const Color booked = Color(0xFFD64545);

  // Neutral typography & borders
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF5E6C84);
  static const Color textMuted = Color(0xFF94A3B8); // verify in Figma
  static const Color borderLight = Color(0xFFE2E8F0); // verify in Figma
  static const Color chipBorder = Color(0xFFE5E7EB); // verify in Figma
  static const Color badgeBg = Color(0xFFF1F5F9); // verify in Figma

  // Warning colors
  static const Color warningBg = Color(0x1AF4A340);
  static const Color warning = Color(0xFFF4A340); // icon circle
  static const Color warningBorder = Color(
    0x66F4A340,
  ); // amber at 40%, estimate
  static const Color warningText = Color(
    0xFF8A5A14,
  ); // estimate, confirm in Figma
}
