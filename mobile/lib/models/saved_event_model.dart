
class SavedEvent {
  final String id;
  final String eventId;
  final String userId;
  final DateTime createdAt;

  const SavedEvent({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.createdAt,
  });
}