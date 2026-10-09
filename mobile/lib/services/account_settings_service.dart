import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsService {
  static final ValueNotifier<bool> darkModeEnabled = ValueNotifier(false);

  static String _key(String setting) {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      return 'sportspace_${setting}_$uid';
    } catch (_) {
      return 'sportspace_${setting}_guest';
    }
  }

  static Future<bool> loadDarkMode() async {
    final enabled = await readDarkMode();
    darkModeEnabled.value = enabled;
    return enabled;
  }

  // Read a user's saved preference without rebuilding the app's root widget
  // tree. Use this while a screen is loading its account-specific settings.
  static Future<bool> readDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_key('dark_mode')) ?? false;
  }

  static Future<void> setDarkMode(bool enabled) async {
    darkModeEnabled.value = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_key('dark_mode'), enabled);
  }

  static Future<bool> loadNotificationsEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_key('notifications')) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_key('notifications'), enabled);
  }
}
