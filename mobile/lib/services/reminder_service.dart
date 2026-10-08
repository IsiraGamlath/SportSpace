
import 'package:flutter/foundation.dart';
import '../models/reminder_subscription_model.dart';

class ReminderService extends ChangeNotifier {
  final Map<String, ReminderSubscription> _subscriptions = {}; // keyed by eventId

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

  bool isSubscribed(String eventId) => _subscriptions.containsKey(eventId);

  /// CREATE — subscribe to reminders for [eventId].
  void subscribe(String eventId) {
    if (_subscriptions.containsKey(eventId)) return;

    final subscription = ReminderSubscription(
      id: '${eventId}_$_currentUserId',
      eventId: eventId,
      userId: _currentUserId,
      createdAt: DateTime.now(),
    );
    _subscriptions[eventId] = subscription;
    notifyListeners();

    // TODO(backend): persist + register for push notifications, e.g.
    //   await FirebaseFirestore.instance
    //     .collection('reminders').doc(subscription.id)
    //     .set({
    //       'eventId': subscription.eventId,
    //       'userId': subscription.userId,
    //       'createdAt': subscription.createdAt,
    //     });
    //   await FirebaseMessaging.instance.subscribeToTopic('event_$eventId');
  }

  /// DELETE — unsubscribe from reminders for [eventId].
  void unsubscribe(String eventId) {
    final removed = _subscriptions.remove(eventId);
    if (removed == null) return;
    notifyListeners();

    // TODO(backend): remove persisted subscription + unregister push, e.g.
    //   await FirebaseFirestore.instance.collection('reminders').doc(removed.id).delete();
    //   await FirebaseMessaging.instance.unsubscribeFromTopic('event_$eventId');
  }

  void toggle(String eventId) {
    isSubscribed(eventId) ? unsubscribe(eventId) : subscribe(eventId);
  }

  List<ReminderSubscription> get activeSubscriptions =>
      List.unmodifiable(_subscriptions.values);

  /// Clears all state. This service is an app-wide singleton, so
  /// widget tests call this in setUp() to avoid state leaking between
  /// tests — see test/event_details_view_test.dart.
  @visibleForTesting
  void resetForTesting() {
    _subscriptions.clear();
    notifyListeners();
  }
}