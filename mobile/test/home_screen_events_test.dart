import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/sport_event_model.dart';
import 'package:mobile/services/app_services.dart';
import 'package:mobile/services/event_repository.dart';
import 'package:mobile/views/home_screen.dart';
import 'package:mobile/views/tertiary/event_details_view.dart';
import 'package:mobile/views/tertiary/events_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void _setScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appServices.bookmarkService.resetForTesting();
    appServices.reminderService.resetForTesting();
    appServices.contactRequestService.resetForTesting();
    appServices.notificationService.resetForTesting();
    appServices.eventRepository.resetForTesting();
  });

  testWidgets('HomeScreen fetches and displays live database events from eventRepository', (tester) async {
    _setScreenSize(tester);

    // Initial default events from repository
    expect(appServices.eventRepository.currentEvents.isNotEmpty, isTrue);
    final firstEventTitle = appServices.eventRepository.currentEvents.first.title;

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Confirm section header exists
    expect(find.text('Community Events'), findsOneWidget);

    // Confirm live repository event title is displayed on screen
    expect(find.text(firstEventTitle), findsWidgets);

    // Confirm hardcoded mock event 'Colombo Weekend 5K Run' from old array is NOT present
    expect(find.text('Colombo Weekend 5K Run'), findsNothing);
  });

  testWidgets('HomeScreen live events update when event is added to eventRepository', (tester) async {
    _setScreenSize(tester);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    const newTitle = 'Galle Live Cricket Tournament 2026';
    final newEvent = NearbyEvent(
      id: 'evt_cricket_live',
      title: newTitle,
      sport: 'Cricket',
      date: 'Tomorrow',
      time: '10:00 AM – 4:00 PM',
      eventDate: DateTime.now().add(const Duration(days: 1)),
      location: 'Galle International Stadium',
      facility: 'Galle Stadium',
      eventType: 'Tournament',
      status: 'Open',
      imageUrl: 'assets/images/cricket.jpg',
    );

    await appServices.eventRepository.createEvent(newEvent);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(newTitle), findsWidgets);
  });

  testWidgets('HomeScreen tapping event opens EventDetailsView and View All opens EventsView', (tester) async {
    _setScreenSize(tester);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final firstEvent = appServices.eventRepository.currentEvents.first;
    final eventFinder = find.text(firstEvent.title);
    expect(eventFinder, findsWidgets);

    // Tap on the event card
    await tester.tap(eventFinder.first);
    await tester.pumpAndSettle();

    // Verifies navigation to EventDetailsView
    expect(find.byType(EventDetailsView), findsOneWidget);
  });
}
