
import '../models/sport_event_model.dart';

abstract class EventRepository {
  Future<List<NearbyEvent>> getEvents();
}

class MockEventRepository implements EventRepository {
  static final List<NearbyEvent> _events = [
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

  @override
  Future<List<NearbyEvent>> getEvents() async => _events;
}