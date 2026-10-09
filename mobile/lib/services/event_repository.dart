import 'package:flutter/material.dart';
import '../models/sport_event_model.dart';
import '../models/app_notification_model.dart';
import 'api_service.dart';
import 'app_services.dart';

abstract class EventRepository {
  Future<List<NearbyEvent>> getEvents();
  Future<NearbyEvent> createEvent(NearbyEvent event);
  Future<NearbyEvent> updateEvent(NearbyEvent event);
  Future<void> cancelEvent(String id);
  void resetForTesting();
}

class MockEventRepository implements EventRepository {
  static final List<NearbyEvent> _defaultEvents = [
    NearbyEvent(
      id: 'evt_badminton_open',
      title: 'Colombo Community Badminton Open',
      sport: 'Badminton',
      date: '20 September 2026',
      time: '9:00 AM – 5:00 PM',
      eventDate: DateTime(2026, 9, 20),
      location: 'Colombo Sports Hub, Colombo',
      facility: 'Colombo Sports Hub',
      eventType: 'Tournament',
      status: 'Open',
      imageUrl: 'assets/images/badminton.jpg',
      description:
          'An open community badminton tournament welcoming players of all '
          'skill levels, with singles and doubles categories and on-site '
          'equipment rental.',
      organizerName: 'Colombo Community Sports Association',
      organizerInitials: 'CC',
      timeline: const [
        EventTimelineItem(time: '09:00 AM', label: 'Registration'),
        EventTimelineItem(time: '10:00 AM', label: 'Opening Matches'),
        EventTimelineItem(time: '12:30 PM', label: 'Lunch Break'),
        EventTimelineItem(time: '01:30 PM', label: 'Quarter Finals'),
        EventTimelineItem(time: '04:00 PM', label: 'Finals'),
      ],
    ),
    NearbyEvent(
      id: 'evt_football_training',
      title: 'Youth Football Training Day',
      sport: 'Football',
      date: '22 September 2026',
      time: '4:00 PM – 7:00 PM',
      eventDate: DateTime(2026, 9, 22),
      location: 'City Sports Ground, Colombo',
      facility: 'City Sports Ground',
      eventType: 'Training',
      status: 'Confirmed',
      imageUrl: 'assets/images/football.jpg',
      description:
          'A structured training session for youth players focused on '
          'fundamentals, drills, and a friendly scrimmage to close the day.',
      organizerName: 'City Youth Football Club',
      organizerInitials: 'CY',
      timeline: const [
        EventTimelineItem(time: '04:00 PM', label: 'Warm-up'),
        EventTimelineItem(time: '04:30 PM', label: 'Skills Drills'),
        EventTimelineItem(time: '06:00 PM', label: 'Scrimmage Match'),
        EventTimelineItem(time: '06:45 PM', label: 'Cool Down & Feedback'),
      ],
    ),
    NearbyEvent(
      id: 'evt_basketball_league',
      title: 'Weekend Basketball League',
      sport: 'Basketball',
      date: '19 September 2026',
      time: '2:00 PM – 6:00 PM',
      eventDate: DateTime(2026, 9, 19),
      location: 'Downtown Arena, Colombo',
      facility: 'Downtown Arena',
      eventType: 'League',
      status: 'Open',
      imageUrl:
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200&q=80',
      description:
          'Weekly league matches open to registered teams, with standings '
          'updated after every round.',
      organizerName: 'Downtown Basketball League',
      organizerInitials: 'DB',
      timeline: const [
        EventTimelineItem(time: '02:00 PM', label: 'Check-in'),
        EventTimelineItem(time: '02:30 PM', label: 'Round 1 Matches'),
        EventTimelineItem(time: '04:30 PM', label: 'Round 2 Matches'),
        EventTimelineItem(time: '05:45 PM', label: 'Standings & Close'),
      ],
    ),
  ];

  final List<NearbyEvent> _events = List.from(_defaultEvents);

  @override
  Future<List<NearbyEvent>> getEvents() async {
    try {
      final backendList = await ApiService.fetchEvents();
      if (backendList.isNotEmpty) {
        final parsed = backendList.map((e) => NearbyEvent.fromJson(e)).toList();
        _events.clear();
        _events.addAll(parsed);
      }
    } catch (_) {
      // Offline fallback
    }
    return List.unmodifiable(_events);
  }

  @override
  Future<NearbyEvent> createEvent(NearbyEvent event) async {
    _events.insert(0, event);

    ApiService.createEvent({
      'title': event.title,
      'sport': event.sport,
      'date': event.date,
      'time': event.time,
      'location': event.location,
      'facility': event.facility,
      'eventType': event.eventType,
      'status': event.status,
      'description': event.description,
      'organizerName': event.organizerName,
      'organizerInitials': event.organizerInitials,
      'imageUrl': event.imageUrl,
    }).catchError((_) => <String, dynamic>{});

    // Requirement 5: when player creates an event, notify player, facility manager, community member
    appServices.notificationService.dispatchNotification(
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: NotificationCategory.schedule,
      title: 'New Event Scheduled',
      message: '${event.title} has been scheduled for ${event.date} at ${event.time}.',
      accentColor: const Color(0xFFDF8420), // Orange
    );

    return event;
  }

  @override
  Future<NearbyEvent> updateEvent(NearbyEvent event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _events[idx] = event;
    }

    ApiService.updateEvent(event.id, {
      'title': event.title,
      'sport': event.sport,
      'date': event.date,
      'time': event.time,
      'location': event.location,
      'facility': event.facility,
      'status': event.status,
      'description': event.description,
    }).catchError((_) => <String, dynamic>{});

    // Requirement 5: when player edits an event, notify player, facility manager, community member
    appServices.notificationService.dispatchNotification(
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: NotificationCategory.schedule,
      title: 'Schedule Updated',
      message: '${event.title} — schedule/start time was updated to ${event.time}.',
      accentColor: const Color(0xFFDF8420), // Orange
    );

    return event;
  }

  @override
  Future<void> cancelEvent(String id) async {
    final idx = _events.indexWhere((e) => e.id == id);
    String title = 'Event';
    if (idx != -1) {
      final old = _events[idx];
      title = old.title;
      _events[idx] = NearbyEvent(
        id: old.id,
        title: old.title,
        sport: old.sport,
        date: old.date,
        time: old.time,
        eventDate: old.eventDate,
        location: old.location,
        facility: old.facility,
        eventType: old.eventType,
        status: 'Cancelled',
        imageUrl: old.imageUrl,
        description: old.description,
        organizerName: old.organizerName,
        organizerInitials: old.organizerInitials,
        timeline: old.timeline,
      );
    }

    ApiService.cancelEvent(id).catchError((_) => <String, dynamic>{});

    // Requirement 5: when player cancels an event, notify player, facility manager, community member
    appServices.notificationService.dispatchNotification(
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: NotificationCategory.event,
      title: 'Event Cancelled',
      message: '$title has been postponed or cancelled.',
      accentColor: const Color(0xFFE14C4C), // Red
    );
  }

  @visibleForTesting
  void resetForTesting() {
    _events.clear();
    _events.addAll(_defaultEvents);
  }
}