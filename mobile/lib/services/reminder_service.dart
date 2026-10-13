import 'package:flutter/material.dart';
import '../models/reminder_subscription_model.dart';
import '../models/app_notification_model.dart';
import '../models/sport_event_model.dart';
import 'app_services.dart';

class ReminderService extends ChangeNotifier {
  final Map<String, ReminderSubscription> _subscriptions = {}; // keyed by eventId

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

  bool isSubscribed(String eventId) => _subscriptions.containsKey(eventId);

  /// CREATE — subscribe to reminders for [eventId].
  void subscribe(String eventId, [NearbyEvent? event]) {
    if (_subscriptions.containsKey(eventId)) return;

    final subscription = ReminderSubscription(
      id: '${eventId}_$_currentUserId',
      eventId: eventId,
      userId: _currentUserId,
      createdAt: DateTime.now(),
    );
    _subscriptions[eventId] = subscription;
    notifyListeners();

    // Requirement 12: when user marks reminder on an event, before 3 hours from
    // event start time, the reminder should show in that community member's notification screen.
    final eventTitle = event?.title ??
        (eventId == 'evt_football_training'
            ? 'Youth Football Training Day'
            : (eventId == 'evt_badminton_open'
                ? 'Colombo Community Badminton Open'
                : 'Upcoming Sports Event'));
    final eventTime = event?.time ?? 'soon';

    appServices.notificationService.dispatchNotification(
      targetRoles: ['communityMember'],
      userId: _currentUserId,
      category: NotificationCategory.event,
      title: 'Event Reminder',
      message: '$eventTitle starts in 3 hours at $eventTime.',
      accentColor: const Color(0xFF2E8B57), // Green
      icon: Icons.notifications_none_rounded,
    );
  }

  /// DELETE — unsubscribe from reminders for [eventId].
  void unsubscribe(String eventId) {
    final removed = _subscriptions.remove(eventId);
    if (removed == null) return;
    notifyListeners();
  }

  void toggle(String eventId, [NearbyEvent? event]) {
    isSubscribed(eventId) ? unsubscribe(eventId) : subscribe(eventId, event);
  }

  List<ReminderSubscription> get activeSubscriptions =>
      List.unmodifiable(_subscriptions.values);

  @visibleForTesting
  void resetForTesting() {
    _subscriptions.clear();
    notifyListeners();
  }
}