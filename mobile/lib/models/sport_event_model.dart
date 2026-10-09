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

  factory NearbyEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['eventDate'] != null) {
      parsedDate =
          DateTime.tryParse(json['eventDate'].toString()) ?? DateTime(2026, 9, 20);
    } else {
      parsedDate = DateTime(2026, 9, 20);
    }

    final timelineList = <EventTimelineItem>[];
    if (json['timeline'] is List) {
      for (final t in json['timeline']) {
        if (t is Map) {
          timelineList.add(
            EventTimelineItem(
              time: t['time'] as String? ?? '',
              label: t['label'] as String? ?? '',
            ),
          );
        }
      }
    }

    return NearbyEvent(
      id: json['id'] as String? ?? json['_id'] as String? ?? 'evt_${json['title']}',
      title: json['title'] as String? ?? '',
      sport: json['sport'] as String? ?? 'Badminton',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      eventDate: parsedDate,
      location: json['location'] as String? ?? 'Colombo',
      facility: json['facility'] as String? ?? json['location'] as String? ?? '',
      eventType: json['eventType'] as String? ?? 'Tournament',
      status: json['status'] as String? ?? 'Open',
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/badminton.jpg',
      description: json['description'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? '',
      organizerInitials: json['organizerInitials'] as String? ?? '',
      timeline: timelineList,
    );
  }
}