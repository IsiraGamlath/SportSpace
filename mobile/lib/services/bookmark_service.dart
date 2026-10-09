
import 'package:flutter/foundation.dart';
import '../models/saved_event_model.dart';

class BookmarkService extends ChangeNotifier {
  final Map<String, SavedEvent> _savedByEventId = {}; // keyed by eventId

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

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

    // TODO(backend): persist, e.g.
    //   final saved = _savedByEventId[eventId]!;
    //   await FirebaseFirestore.instance
    //     .collection('saved_events').doc(saved.id)
    //     .set({
    //       'eventId': saved.eventId,
    //       'userId': saved.userId,
    //       'createdAt': saved.createdAt,
    //     });
  }

  /// DELETE — unsave/unbookmark [eventId] for the current user.
  void unsave(String eventId) {
    final removed = _savedByEventId.remove(eventId);
    if (removed == null) return;
    notifyListeners();

    // TODO(backend): delete the corresponding Firestore doc, e.g.
    //   await FirebaseFirestore.instance
    //     .collection('saved_events').doc(removed.id).delete();
  }

  void toggle(String eventId) {
    isSaved(eventId) ? unsave(eventId) : save(eventId);
  }

  List<SavedEvent> get savedEvents =>
      List.unmodifiable(_savedByEventId.values);

  /// Clears all state. This service is an app-wide singleton, so
  /// widget tests call this in setUp() to avoid state leaking between
  /// tests — see test/event_details_view_test.dart.
  @visibleForTesting
  void resetForTesting() {
    _savedByEventId.clear();
    notifyListeners();
  }
}