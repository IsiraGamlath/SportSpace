import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static String get _storageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'sportspace_favorites_$uid';
  }

  static Future<Set<String>> loadFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_storageKey) ?? <String>[]).toSet();
  }

  /// Returns true when the facility is a favorite after this change.
  static Future<bool> toggleFavorite(String facilityName) async {
    final preferences = await SharedPreferences.getInstance();
    final favorites = (preferences.getStringList(_storageKey) ?? <String>[])
        .toSet();
    final isFavorite = !favorites.remove(facilityName);
    if (isFavorite) favorites.add(facilityName);
    await preferences.setStringList(_storageKey, favorites.toList());
    return isFavorite;
  }
}
