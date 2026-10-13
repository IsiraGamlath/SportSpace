import 'package:flutter/material.dart';
import '../models/sport_event_model.dart';
import '../models/app_notification_model.dart';
import 'api_service.dart';
import 'app_services.dart';

abstract class EventRepository {
  Future<List<NearbyEvent>> getEvents({bool forceRefresh = false});
  List<NearbyEvent> get currentEvents;
  NearbyEvent? getEventById(String id);
  Future<NearbyEvent> createEvent(NearbyEvent event);
  Future<NearbyEvent> updateEvent(NearbyEvent event);
  Future<NearbyEvent> toggleParticipation(String eventId, String userId);
  Future<void> cancelEvent(String id);
  Future<bool> deleteEvent(String id);
  void resetForTesting();
}

class MockEventRepository extends ChangeNotifier implements EventRepository {
  static List<NearbyEvent> get _defaultEvents => [
    NearbyEvent(
      id: 'evt_badminton_today',
      title: 'Open Badminton Friendly Match',
      sport: 'Badminton',
      date: 'Today',
      time: '5:00 PM – 7:00 PM',
      eventDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      location: 'Colombo Sports Hub, Colombo',
      facility: 'Colombo Sports Hub',
      eventType: 'Friendly',
      status: 'Open',
      imageUrl: 'assets/images/badminton.jpg',
      description:
          'Community friendly matches open to all badminton enthusiasts today at Colombo Sports Hub.',
      organizerName: 'Colombo Community Sports Association',
      organizerInitials: 'CC',
      timeline: const [
        EventTimelineItem(time: '05:00 PM', label: 'Warm-up & Rally'),
        EventTimelineItem(time: '05:30 PM', label: 'Friendly Matches'),
        EventTimelineItem(time: '06:45 PM', label: 'Cool Down'),
      ],
    ),
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
  ];

  final List<NearbyEvent> _events = List.from(_defaultEvents);

  MockEventRepository() {
    getEvents();
  }

  @override
  List<NearbyEvent> get currentEvents => List.unmodifiable(_events);

  @override
  NearbyEvent? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  bool _isFetching = false;

  @override
  Future<List<NearbyEvent>> getEvents({bool forceRefresh = false}) async {
    if (_isFetching) return List.unmodifiable(_events);
    _isFetching = true;
    try {
      final backendList = await ApiService.fetchEvents();
      if (backendList.isNotEmpty) {
        final parsed = backendList.map((e) => NearbyEvent.fromJson(e)).toList();
        _events.clear();
        _events.addAll(parsed);
        notifyListeners();
      }
    } catch (_) {
      // Offline fallback
    } finally {
      _isFetching = false;
    }
    return List.unmodifiable(_events);
  }

  @override
  Future<NearbyEvent> createEvent(NearbyEvent event) async {
    try {
      final res = await ApiService.createEvent({
        'title': event.title,
        'sport': event.sport,
        'date': event.date,
        'time': event.time,
        'eventDate': event.eventDate.toIso8601String(),
        'location': event.location,
        'facility': event.facility,
        'facilityId': event.facilityId,
        'eventType': event.eventType,
        'status': event.status,
        'description': event.description,
        'organizerName': event.organizerName,
        'organizerInitials': event.organizerInitials,
        'imageUrl': event.imageUrl,
        'capacity': event.capacity,
        'participants': event.participants,
        'participantCount': event.participantCount,
      });

      final created = NearbyEvent.fromJson(res);
      _events.removeWhere((e) => e.id == event.id || e.id == created.id);
      _events.insert(0, created);

      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager', 'communityMember'],
        category: NotificationCategory.schedule,
        title: 'New Event Scheduled',
        message: '${created.title} has been scheduled for ${created.date} at ${created.time}.',
        accentColor: const Color(0xFFDF8420), // Orange
      );

      notifyListeners();
      return created;
    } catch (_) {
      _events.removeWhere((e) => e.id == event.id);
      _events.insert(0, event);

      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager', 'communityMember'],
        category: NotificationCategory.schedule,
        title: 'New Event Scheduled',
        message: '${event.title} has been scheduled for ${event.date} at ${event.time}.',
        accentColor: const Color(0xFFDF8420),
      );

      notifyListeners();
      return event;
    }
  }

  @override
  Future<NearbyEvent> toggleParticipation(String eventId, String userId) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx == -1) {
      throw Exception('Event not found');
    }
    final event = _events[idx];
    final isAlready = event.participants.contains(userId);
    final List<String> newParticipants = List.from(event.participants);
    if (isAlready) {
      newParticipants.remove(userId);
    } else {
      if (event.isFull) {
        throw Exception('Event is already full');
      }
      newParticipants.add(userId);
    }
    final updated = event.copyWith(
      participants: newParticipants,
      participantCount: newParticipants.length,
    );
    _events[idx] = updated;

    ApiService.toggleEventParticipation(eventId, userId: userId).catchError((_) => <String, dynamic>{});

    notifyListeners();
    return updated;
  }

  @override
  Future<NearbyEvent> updateEvent(NearbyEvent event) async {
    try {
      final res = await ApiService.updateEvent(event.id, {
        'title': event.title,
        'sport': event.sport,
        'date': event.date,
        'time': event.time,
        'eventDate': event.eventDate.toIso8601String(),
        'location': event.location,
        'facility': event.facility,
        'facilityId': event.facilityId,
        'eventType': event.eventType,
        'status': event.status,
        'description': event.description,
        'capacity': event.capacity,
      });

      final updated = NearbyEvent.fromJson(res);
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        _events[idx] = updated;
      } else {
        _events.insert(0, updated);
      }

      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager', 'communityMember'],
        category: NotificationCategory.schedule,
        title: 'Schedule Updated',
        message: '${updated.title} — schedule/start time was updated to ${updated.time}.',
        accentColor: const Color(0xFFDF8420),
      );

      notifyListeners();
      return updated;
    } catch (_) {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        _events[idx] = event;
      }

      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager', 'communityMember'],
        category: NotificationCategory.schedule,
        title: 'Schedule Updated',
        message: '${event.title} — schedule/start time was updated to ${event.time}.',
        accentColor: const Color(0xFFDF8420),
      );

      notifyListeners();
      return event;
    }
  }

  @override
  Future<void> cancelEvent(String id) async {
    final idx = _events.indexWhere((e) => e.id == id);
    String title = 'Event';
    if (idx != -1) {
      final old = _events[idx];
      title = old.title;
      _events[idx] = old.copyWith(status: 'Cancelled');
    }

    ApiService.cancelEvent(id).catchError((_) => <String, dynamic>{});

    appServices.notificationService.dispatchNotification(
      targetRoles: ['player', 'facilityManager', 'communityMember'],
      category: NotificationCategory.event,
      title: 'Event Cancelled',
      message: '$title has been postponed or cancelled.',
      accentColor: const Color(0xFFE14C4C), // Red
    );

    notifyListeners();
  }

  @override
  Future<bool> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      return await ApiService.deleteEvent(id);
    } catch (_) {
      return true;
    }
  }

  @override
  @visibleForTesting
  void resetForTesting() {
    _events.clear();
    _events.addAll(_defaultEvents);
    notifyListeners();
  }
}