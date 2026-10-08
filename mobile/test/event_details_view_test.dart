
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/sport_event_model.dart';
import 'package:mobile/services/app_services.dart';
import 'package:mobile/views/tertiary/event_details_view.dart';
import 'package:mobile/views/tertiary/facility_details_view.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  late NearbyEvent event;

  setUp(() {
    // Services are app-wide singletons — reset between tests so a
    // Save/Reminder toggle in one test never leaks into the next.
    appServices.bookmarkService.resetForTesting();
    appServices.reminderService.resetForTesting();

    event = NearbyEvent(
      id: 'evt_test_badminton',
      title: 'Colombo Community Badminton Open',
      sport: 'Badminton',
      date: '20 September 2026',
      time: '9:00 AM – 5:00 PM',
      eventDate: DateTime(2026, 9, 20),
      location: 'Colombo Sports Hub, Colombo',
      facility: 'Colombo Sports Hub',
      eventType: 'Tournament',
      status: 'Open',
      imageUrl:
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=1200&q=80',
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
    );
  });

  group('EventDetailsView rendering', () {
    testWidgets('shows core event information', (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('Colombo Community Badminton Open'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Badminton'), findsOneWidget);
      expect(find.text('20 September 2026'), findsOneWidget);
      expect(find.text('9:00 AM – 5:00 PM'), findsOneWidget);
      expect(find.text('Colombo Sports Hub, Colombo'), findsOneWidget);
      expect(
        find.textContaining('open community badminton tournament'),
        findsOneWidget,
      );
    });

    testWidgets('shows organizer section', (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('Organizer'), findsOneWidget);
      expect(
        find.text('Colombo Community Sports Association'),
        findsOneWidget,
      );
      expect(find.text('CC'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
    });

    testWidgets('shows event timeline entries', (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('Event Timeline'), findsOneWidget);
      expect(find.text('Registration'), findsOneWidget);
      expect(find.text('Finals'), findsOneWidget);
      expect(find.text('04:00 PM'), findsOneWidget);
    });
  });

  group('Save / Bookmark', () {
    testWidgets('tapping Save marks the event as saved', (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(appServices.bookmarkService.isSaved(event.id), isFalse);
      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(appServices.bookmarkService.isSaved(event.id), isTrue);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('tapping Saved again unsaves the event', (tester) async {
      appServices.bookmarkService.save(event.id);

      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();

      expect(appServices.bookmarkService.isSaved(event.id), isFalse);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('Remind Me subscription', () {
    testWidgets('tapping Remind Me creates a subscription', (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(appServices.reminderService.isSubscribed(event.id), isFalse);
      expect(find.text('Remind Me'), findsOneWidget);

      await tester.tap(find.text('Remind Me'));
      await tester.pumpAndSettle();

      expect(appServices.reminderService.isSubscribed(event.id), isTrue);
      expect(find.text('Reminder On'), findsOneWidget);
    });

    testWidgets('tapping Reminder On deletes the subscription',
        (tester) async {
      appServices.reminderService.subscribe(event.id);

      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('Reminder On'), findsOneWidget);

      await tester.tap(find.text('Reminder On'));
      await tester.pumpAndSettle();

      expect(appServices.reminderService.isSubscribed(event.id), isFalse);
      expect(find.text('Remind Me'), findsOneWidget);
    });
  });

  group('View Facility navigation', () {
    testWidgets('tapping View Facility opens FacilityDetailsView',
        (tester) async {
      await tester.pumpWidget(_wrap(EventDetailsView(event: event)));
      await tester.pumpAndSettle();

      expect(find.text('View Facility'), findsOneWidget);

      await tester.tap(find.text('View Facility'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityDetailsView), findsOneWidget);
    });
  });
}