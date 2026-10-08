

class ReminderSubscription {
  final String id;
  final String eventId;
  final String userId;
  final DateTime createdAt;

  const ReminderSubscription({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.createdAt,
  });
}