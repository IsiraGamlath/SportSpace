import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/sport_event_model.dart';
import 'package:mobile/services/app_services.dart';
import 'package:mobile/services/event_repository.dart';
import 'package:mobile/views/manager/manager_create_event_screen.dart';
import 'package:mobile/widgets/tertiary/nearby_event_card.dart';

void main() {
  setUp(() {
    appServices.eventRepository.resetForTesting();
  });

  group('Event Creation & Participation Flow Tests', () {
    testWidgets('1. Manager Create Event validates required fields and binds chosen assigned facility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManagerCreateEventScreen(
            facilityName: 'Colombo Central Arena',
            facilityId: 'fac_colombo_central',
            facilityLocation: 'Colombo 07, Reid Avenue',
            assignedFacilities: [
              {
                'id': 'fac_colombo_central',
                'name': 'Colombo Central Arena',
                'location': 'Colombo 07, Reid Avenue',
              },
              {
                'id': 'fac_kandy_complex',
                'name': 'Kandy Sports Complex',
                'location': 'Kandy City Center',
              },
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check assigned facility section is rendered
      expect(find.text('Host Facility / Venue *'), findsOneWidget);
      expect(find.text('Selected Facility'), findsOneWidget);
      expect(find.text('Colombo Central Arena'), findsWidgets);

      // Attempt to submit empty form
      final submitButton = find.widgetWithText(ElevatedButton, 'Publish Event');
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Required field error for title
      expect(find.text('Please enter the event name'), findsOneWidget);

      // Fill valid event details
      final titleField = find.widgetWithText(TextFormField, 'e.g. Colombo Open Badminton Championship 2026');
      await tester.ensureVisible(titleField);
      await tester.enterText(
        titleField,
        'Colombo Super Cup 2026',
      );
      final descField = find.widgetWithText(TextFormField, 'Provide details about registration, matches, equipment, rules, and who can participate...');
      await tester.ensureVisible(descField);
      await tester.enterText(
        descField,
        'Open badminton tournament for all local club members with exciting prizes.',
      );
      await tester.pumpAndSettle();

      // Submit form
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify event was saved to repository with active facility bound
      final events = await appServices.eventRepository.getEvents();
      final created = events.firstWhere((e) => e.title == 'Colombo Super Cup 2026');
      expect(created.facility, 'Colombo Central Arena');
      expect(created.facilityId, 'fac_colombo_central');
      expect(created.location, 'Colombo 07, Reid Avenue');
      expect(created.capacity, 30);
      expect(created.participantCount, 0);
    });

    testWidgets('2. Participation Flow - User toggles RSVP on NearbyEventCard with live count and capacity limit', (tester) async {
      // Create a test event with capacity of 2
      final testEvent = NearbyEvent(
        id: 'evt_test_participation',
        title: 'Community Tennis Rally',
        sport: 'Tennis',
        date: 'Tomorrow',
        time: '10:00 AM – 12:00 PM',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        location: 'Colombo Tennis Club',
        facility: 'Colombo Tennis Club',
        facilityId: 'fac_tennis',
        eventType: 'Friendly',
        status: 'Open',
        imageUrl: 'assets/images/badminton.jpg',
        description: 'Casual rally session.',
        organizerName: 'Colombo Tennis Club',
        organizerInitials: 'CT',
        capacity: 2,
        participants: const [],
        participantCount: 0,
      );

      await appServices.eventRepository.createEvent(testEvent);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NearbyEventCard(event: testEvent),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state: 0/2 spots
      expect(find.text('0/2 Spots'), findsOneWidget);
      expect(find.text('RSVP'), findsOneWidget);

      // Tap RSVP
      await tester.tap(find.text('RSVP'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4)); // Let SnackBar dismiss

      // Real time count updates to 1/2 spots, button text updates to "Going"
      expect(find.text('1/2 Spots'), findsOneWidget);
      expect(find.text('Going'), findsOneWidget);

      // Now toggle another participant to hit capacity
      await appServices.eventRepository.toggleParticipation('evt_test_participation', 'second_user');
      await tester.pumpAndSettle();

      // When full, capacity badge updates
      expect(find.text('Full (2/2)'), findsOneWidget);
      // Current user is still "Going"
      expect(find.text('Going'), findsOneWidget);

      // Current user cancels RSVP
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Going'));
      await tester.pumpAndSettle();

      // Count drops to 1/2 Spots and user can RSVP again
      expect(find.text('1/2 Spots'), findsOneWidget);
      expect(find.text('RSVP'), findsOneWidget);
    });

    testWidgets('3. Event Full disables RSVP for non-participating users', (tester) async {
      // Create full event where community_user is not in participants
      final fullEvent = NearbyEvent(
        id: 'evt_full_test',
        title: 'Full Basketball Match',
        sport: 'Basketball',
        date: 'Today',
        time: '4:00 PM – 6:00 PM',
        eventDate: DateTime.now(),
        location: 'Downtown Arena',
        facility: 'Downtown Arena',
        eventType: 'Match',
        status: 'Open',
        imageUrl: 'assets/images/badminton.jpg',
        description: 'Full match session.',
        organizerName: 'Downtown Arena',
        organizerInitials: 'DA',
        capacity: 1,
        participants: const ['other_user_1'],
        participantCount: 1,
      );

      await appServices.eventRepository.createEvent(fullEvent);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearbyEventCard(event: fullEvent),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Full (1/1)'), findsOneWidget);
      expect(find.text('Event Full'), findsOneWidget);
    });
  });
}
