import 'package:flutter/foundation.dart';
import '../models/saved_event_model.dart';
import 'api_service.dart';

class BookmarkService extends ChangeNotifier {
  final Map<String, SavedEvent> _savedByEventId = {}; // keyed by eventId

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

  BookmarkService() {
    loadFromBackend();
  }

  Future<void> loadFromBackend() async {
    try {
      final backendList = await ApiService.fetchSavedEvents(userId: _currentUserId);
      if (backendList.isNotEmpty) {
        for (final item in backendList) {
          final eventId = item['eventId'] as String?;
          if (eventId != null && eventId.isNotEmpty) {
            _savedByEventId[eventId] = SavedEvent(
              id: item['id'] as String? ?? '${eventId}_$_currentUserId',
              eventId: eventId,
              userId: _currentUserId,
              createdAt: item['createdAt'] != null
                  ? DateTime.tryParse(item['createdAt'].toString()) ?? DateTime.now()
                  : DateTime.now(),
            );
          }
        }
        notifyListeners();
      }
    } catch (_) {
      // Offline fallback
    }
  }

  bool isSaved(String eventId) => _savedByEventId.containsKey(eventId);

  /// CREATE — save/bookmark [eventId] for the current user.
  void save(String eventId) {
    if (_savedByEventId.containsKey(eventId)) return;

    _savedByEventId[eventId] = SavedEvent(
      id: '${eventId}_$_currentUserId',
      eventId: eventId,
      userId: _currentUserId,
      createdAt: DateTime.now(),
    );
    notifyListeners();

    // Push to backend
    ApiService.saveEvent(eventId, userId: _currentUserId).catchError((_) => <String, dynamic>{});
  }

  /// DELETE — unsave/unbookmark [eventId] for the current user.
  void unsave(String eventId) {
    final removed = _savedByEventId.remove(eventId);
    if (removed == null) return;
    notifyListeners();

    // Push delete to backend
    ApiService.unsaveEvent(eventId, userId: _currentUserId).catchError((_) => false);
  }

  void toggle(String eventId) {
    isSaved(eventId) ? unsave(eventId) : save(eventId);
  }

  List<SavedEvent> get savedEvents =>
      List.unmodifiable(_savedByEventId.values);

  @visibleForTesting
  void resetForTesting() {
    _savedByEventId.clear();
    notifyListeners();
  }
}