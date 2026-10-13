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
  final String facilityId;

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
  final int capacity;
  final List<String> participants;
  final int participantCount;

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
    this.facilityId = 'colombo_sports_hub',
    this.eventType = 'General',
    this.description = '',
    this.organizerName = '',
    this.organizerInitials = '',
    this.timeline = const [],
    this.capacity = 50,
    this.participants = const [],
    this.participantCount = 0,
  });

  bool isParticipating(String userId) =>
      participants.contains(userId) || (userId.isNotEmpty && participants.any((p) => p == userId));

  bool get isFull => capacity > 0 && participantCount >= capacity;
  int get availableSpots => capacity > 0 ? (capacity - participantCount).clamp(0, capacity) : 999;

  NearbyEvent copyWith({
    String? id,
    String? title,
    String? sport,
    String? date,
    String? time,
    DateTime? eventDate,
    String? location,
    String? facility,
    String? facilityId,
    String? eventType,
    String? status,
    String? imageUrl,
    String? description,
    String? organizerName,
    String? organizerInitials,
    List<EventTimelineItem>? timeline,
    int? capacity,
    List<String>? participants,
    int? participantCount,
  }) {
    return NearbyEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      sport: sport ?? this.sport,
      date: date ?? this.date,
      time: time ?? this.time,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      facility: facility ?? this.facility,
      facilityId: facilityId ?? this.facilityId,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      organizerName: organizerName ?? this.organizerName,
      organizerInitials: organizerInitials ?? this.organizerInitials,
      timeline: timeline ?? this.timeline,
      capacity: capacity ?? this.capacity,
      participants: participants ?? this.participants,
      participantCount: participantCount ?? this.participantCount,
    );
  }

  factory NearbyEvent.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = (json['date'] as String? ?? '').toLowerCase().trim();

    if (dateStr == 'today') {
      parsedDate = today;
    } else if (dateStr == 'tomorrow') {
      parsedDate = today.add(const Duration(days: 1));
    } else if (json['eventDate'] != null) {
      final parsed = DateTime.tryParse(json['eventDate'].toString());
      if (parsed != null) {
        parsedDate = parsed.toLocal();
      } else {
        parsedDate = today;
      }
    } else {
      parsedDate = today;
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

    final participantsList = <String>[];
    if (json['participants'] is List) {
      for (final p in json['participants']) {
        if (p != null) participantsList.add(p.toString());
      }
    }

    final pCount = (json['participantCount'] as num?)?.toInt() ??
        participantsList.length;

    return NearbyEvent(
      id: json['id'] as String? ?? json['_id'] as String? ?? 'evt_${json['title']}',
      title: json['title'] as String? ?? '',
      sport: json['sport'] as String? ?? 'Badminton',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      eventDate: parsedDate,
      location: json['location'] as String? ?? 'Colombo',
      facility: json['facility'] as String? ?? json['location'] as String? ?? '',
      facilityId: json['facilityId'] as String? ?? 'colombo_sports_hub',
      eventType: json['eventType'] as String? ?? 'Tournament',
      status: json['status'] as String? ?? 'Open',
      imageUrl: json['imageUrl'] as String? ?? 'assets/images/badminton.jpg',
      description: json['description'] as String? ?? '',
      organizerName: json['organizerName'] as String? ?? '',
      organizerInitials: json['organizerInitials'] as String? ?? '',
      timeline: timelineList,
      capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      participants: participantsList,
      participantCount: pCount,
    );
  }
}