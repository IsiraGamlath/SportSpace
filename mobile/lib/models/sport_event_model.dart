
class EventTimelineItem {
  final String time;
  final String label;

  const EventTimelineItem({required this.time, required this.label});
}

class NearbyEvent {
  final String id;
  final String title;
  final String sport;
  final String date; // display string, e.g. '20 September 2026'
  final String time; // display string, e.g. '9:00 AM – 5:00 PM'

  /// Actual calendar day, used for date filtering/sorting (distinct
  /// from the display-only [date] string above).
  final DateTime eventDate;

  final String location;

  /// Facility/venue name — used by Event Details' "View Facility"
  /// action. Falls back to [location] where not set.
  final String facility;

  /// e.g. 'Tournament', 'Training', 'League'.
  final String eventType;

  final String status; // e.g. 'Open', 'Confirmed'

  /// Either an asset path ('assets/images/...') or an http(s) URL —
  /// see EventImage widget for how both are rendered transparently.
  final String imageUrl;

  final String description;
  final String organizerName;
  final String organizerInitials;
  final List<EventTimelineItem> timeline;

  const NearbyEvent({
    required this.id,
    required this.title,
    required this.sport,
    required this.date,
    required this.time,
    required this.eventDate,
    required this.location,
    required this.status,
    required this.imageUrl,
    this.facility = '',
    this.eventType = 'General',
    this.description = '',
    this.organizerName = '',
    this.organizerInitials = '',
    this.timeline = const [],
  });
}