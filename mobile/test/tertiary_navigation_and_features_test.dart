import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/contact_request_model.dart';
import 'package:mobile/models/facility_info_model.dart';
import 'package:mobile/models/sport_event_model.dart';
import 'package:mobile/services/app_services.dart';
import 'package:mobile/views/tertiary/contact_accessibility_view.dart';
import 'package:mobile/views/tertiary/event_details_view.dart';
import 'package:mobile/views/tertiary/events_view.dart';
import 'package:mobile/views/tertiary/facilities_view.dart';
import 'package:mobile/views/tertiary/facility_details_view.dart';
import 'package:mobile/views/tertiary/facility_profile_view.dart';
import 'package:mobile/views/tertiary/home_view.dart';
import 'package:mobile/views/tertiary/notifications_view.dart';
import 'package:mobile/views/tertiary/personal_information_view.dart';
import 'package:mobile/views/tertiary/placeholder_view.dart';
import 'package:mobile/views/tertiary/profile_view.dart';
import 'package:mobile/views/tertiary/my_requests_view.dart';
import 'package:mobile/widgets/tertiary/filter_chip.dart';
import 'package:mobile/widgets/tertiary/nav_bar.dart';
import 'package:mobile/widgets/tertiary/profile_setting_tile.dart';

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
    appServices.bookmarkService.resetForTesting();
    appServices.reminderService.resetForTesting();
    appServices.contactRequestService.resetForTesting();
    appServices.notificationService.resetForTesting();
  });

  group('1. TertiaryHomeView (Home Entry Screen)', () {
    testWidgets('renders home elements and loads mock events', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Good morning, Saantha'), findsOneWidget);
      expect(find.text('Ready to play?'), findsOneWidget);
      expect(find.text('Search facilities, sports or locations'), findsOneWidget);
      expect(find.text('Popular Events'), findsOneWidget);
      expect(find.text('Nearby & Recommended'), findsOneWidget);
      expect(find.byType(TertiaryNavBar), findsOneWidget);
    });

    testWidgets('search bar input filters events on home screen inline',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'badminton');
      await tester.pumpAndSettle();

      expect(find.text('Colombo Community Badminton Open'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('View All tap navigates to EventsView', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.byType(EventsView), findsOneWidget);
    });

    testWidgets('avatar tap navigates to ProfileView', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SS'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileView), findsOneWidget);
    });

    testWidgets('navigation bar taps navigate to respective views',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      // Tap Facilities tab
      await tester.tap(find.text('Facilities'));
      await tester.pumpAndSettle();
      expect(find.byType(FacilitiesView), findsOneWidget);
      expect(find.byType(TertiaryPlaceholderView), findsNothing);

      // Tap Events tab from Facilities
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.byType(EventsView), findsOneWidget);

      // Tap Notifications tab from Events
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsView), findsOneWidget);

      // Tap Profile tab from Notifications
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileView), findsOneWidget);

      // Tap Home tab from Profile
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(TertiaryHomeView), findsOneWidget);
    });
  });

  group('2. EventsView (Events & Schedules, Search, Filters, Date)', () {
    testWidgets('renders search, filter chips, date selector and event list',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      expect(find.text('Events & Schedules'), findsOneWidget);
      expect(find.text('Search events, sports or facilities'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('Saved only'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Event type'), findsOneWidget);
      expect(find.byType(TertiaryNavBar), findsOneWidget);
    });

    testWidgets('Saved only filter chip filters to only bookmarked events',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      expect(find.text('Saved only'), findsOneWidget);

      // Tap Saved only filter chip
      await tester.tap(find.text('Saved only'));
      await tester.pumpAndSettle();

      // No events are saved initially
      expect(find.text('No events match your filters'), findsOneWidget);

      // Save an event
      appServices.bookmarkService.save('evt_badminton_open');
      await tester.pumpAndSettle();

      expect(find.text('Colombo Community Badminton Open'), findsOneWidget);

      // Untoggle Saved only
      await tester.tap(find.text('Saved only'));
      await tester.pumpAndSettle();
    });

    testWidgets('search query filters the event list and can be cleared',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'badminton');
      await tester.pumpAndSettle();

      expect(find.text('Colombo Community Badminton Open'), findsOneWidget);

      // Clear search query
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Search events, sports or facilities'), findsOneWidget);
    });

    testWidgets('tapping an event card navigates to EventDetailsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      // Disable date filter so all events show
      await tester.tap(find.text('Date'));
      await tester.pumpAndSettle();

      final firstEvent = find.text('Colombo Community Badminton Open');
      expect(firstEvent, findsOneWidget);

      await tester.tap(firstEvent);
      await tester.pumpAndSettle();

      expect(find.byType(EventDetailsView), findsOneWidget);
    });
  });

  group('3. EventDetailsView & Event Actions Flow', () {
    late NearbyEvent testEvent;

    setUp(() {
      testEvent = NearbyEvent(
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
        imageUrl: 'assets/images/badminton.jpg',
        description: 'An open tournament welcoming all skill levels.',
        organizerName: 'Colombo Community Sports Association',
        organizerInitials: 'CC',
        timeline: const [
          EventTimelineItem(time: '09:00 AM', label: 'Registration'),
        ],
      );
    });

    testWidgets('Save and Remind Me toggles update local state',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(EventDetailsView(event: testEvent)));
      await tester.pumpAndSettle();

      // Test Save
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      expect(appServices.bookmarkService.isSaved(testEvent.id), isTrue);

      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      expect(appServices.bookmarkService.isSaved(testEvent.id), isFalse);

      // Test Remind Me
      expect(find.text('Remind Me'), findsOneWidget);
      await tester.tap(find.text('Remind Me'));
      await tester.pumpAndSettle();
      expect(find.text('Reminder On'), findsOneWidget);
      expect(appServices.reminderService.isSubscribed(testEvent.id), isTrue);

      await tester.tap(find.text('Reminder On'));
      await tester.pumpAndSettle();
      expect(find.text('Remind Me'), findsOneWidget);
      expect(appServices.reminderService.isSubscribed(testEvent.id), isFalse);
    });

    testWidgets(
        'View Facility button navigates to FacilityDetailsView with facility data',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(EventDetailsView(event: testEvent)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View Facility'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityDetailsView), findsOneWidget);
      // Selected facility name must match the event's facility
      expect(find.text('Colombo Sports Hub'), findsAtLeastNWidgets(1));
    });

    testWidgets('Tappable location row navigates to FacilityDetailsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(EventDetailsView(event: testEvent)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Colombo Sports Hub, Colombo'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityDetailsView), findsOneWidget);
      expect(find.text('Colombo Sports Hub'), findsAtLeastNWidgets(1));
    });
  });

  group('4. FacilitiesView (Listing, Selection, Navigation)', () {
    testWidgets('renders mock facilities listing and search', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const FacilitiesView()));
      await tester.pumpAndSettle();

      expect(find.text('Facilities & Venues (5)'), findsOneWidget);
      expect(
          find.text('Search facilities, sports or locations'), findsOneWidget);
      expect(find.text('Colombo Sports Hub'), findsOneWidget);
      expect(find.text('City Sports Ground'), findsOneWidget);
      expect(find.text('Downtown Arena'), findsOneWidget);
    });

    testWidgets('selecting a facility card navigates to FacilityDetailsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const FacilitiesView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Colombo Sports Hub'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityDetailsView), findsOneWidget);
      expect(find.text('Colombo Sports Hub'), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'filter chips filter facilities correctly and empty state works',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const FacilitiesView()));
      await tester.pumpAndSettle();

      // Tap Swimming filter chip specifically
      final swimmingChip = find.widgetWithText(EventFilterChip, 'Swimming');
      expect(swimmingChip, findsOneWidget);
      await tester.tap(swimmingChip);
      await tester.pumpAndSettle();

      expect(find.text('Metro Aquatic & Fitness Centre'), findsOneWidget);

      // Search for nonexistent facility
      await tester.enterText(find.byType(TextField), 'NonexistentVenue123');
      await tester.pumpAndSettle();

      expect(find.text('No facilities found'), findsOneWidget);
      expect(find.text('Reset search & filters'), findsOneWidget);

      // Reset
      await tester.tap(find.text('Reset search & filters'));
      await tester.pumpAndSettle();
      expect(find.text('Colombo Sports Hub'), findsOneWidget);
    });
  });

  group('5. FacilityDetailsView & Contact Navigation', () {
    testWidgets('renders facility information and back navigation works',
        (tester) async {
      _setScreenSize(tester);
      final facility = kMockFacilities.first;

      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FacilityDetailsView(
                    title: facility.name,
                    imageUrl: facility.imageUrl,
                    status: facility.status,
                    cityLocation: facility.cityLocation,
                    scheduleTimeRange: facility.scheduleTimeRange,
                    scheduleEventTitle: facility.scheduleEventTitle,
                    openingHours: facility.openingHours,
                    availableSports: facility.availableSports,
                    amenities: facility.amenities,
                    upcomingEvents: facility.upcomingEvents,
                    accessibilityNote: facility.accessibilityNote,
                    facilityId: facility.id,
                    facilityName: facility.name,
                    phone: facility.phone,
                    email: facility.email,
                    address: facility.address,
                  ),
                ),
              ),
              child: const Text('Open Facility'),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Facility'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityDetailsView), findsOneWidget);
      expect(find.text('Colombo Sports Hub'), findsOneWidget);
      expect(find.text("Today's Public Schedule"), findsOneWidget);
      expect(find.text('Sports available'), findsOneWidget);
      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);

      // Test back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(FacilityDetailsView), findsNothing);
    });

    testWidgets(
        'Contact & view Accessibility button navigates to ContactAccessibilityView',
        (tester) async {
      _setScreenSize(tester);
      final facility = kMockFacilities.first;

      await tester.pumpWidget(
        _wrap(
          FacilityDetailsView(
            title: facility.name,
            imageUrl: facility.imageUrl,
            facilityId: facility.id,
            facilityName: facility.name,
            phone: facility.phone,
            email: facility.email,
            address: facility.address,
            openingHours: facility.openingHours,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contact & view Accessibility'));
      await tester.pumpAndSettle();

      expect(find.byType(ContactAccessibilityView), findsOneWidget);
      expect(find.text('Colombo Sports Hub'), findsOneWidget);
    });

    testWidgets(
        'View full facility profile link navigates to FacilityProfileView with complete description',
        (tester) async {
      _setScreenSize(tester);
      final facility = kMockFacilities.first;

      await tester.pumpWidget(
        _wrap(
          FacilityDetailsView(
            title: facility.name,
            imageUrl: facility.imageUrl,
            facilityId: facility.id,
            facilityName: facility.name,
            phone: facility.phone,
            email: facility.email,
            address: facility.address,
            openingHours: facility.openingHours,
            availableSports: facility.availableSports,
            amenities: facility.amenities,
            accessibilityNote: facility.accessibilityNote,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amenities'), findsOneWidget);
      expect(find.text('Parking'), findsOneWidget);
      expect(find.text('Changing rooms'), findsOneWidget);

      await tester.ensureVisible(find.text('View full facility profile →'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View full facility profile →'));
      await tester.pumpAndSettle();

      expect(find.byType(FacilityProfileView), findsOneWidget);
      expect(find.text('About Facility'), findsOneWidget);
      expect(find.text('Contact & Location'), findsOneWidget);
      expect(find.text('Booking Guidelines & Rates'), findsOneWidget);
    });
  });

  group(
      '6. ContactAccessibilityView & Request Form (Create, Edit, Delete, Validation)',
      () {
    testWidgets('submitting empty form shows validation error', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(
        _wrap(
          const ContactAccessibilityView(
            facilityId: 'colombo_sports_hub',
            facilityName: 'Colombo Sports Hub',
            phone: '+94 11 234 5678',
            email: 'info@colombosportshub.lk',
            address: 'Colombo 07',
            openingHours: '6AM - 10PM',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submit Request'), findsOneWidget);
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please describe your enquiry or accessibility needs.'),
        findsOneWidget,
      );
    });

    testWidgets('create, edit, and delete request flow works with local state',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(
        _wrap(
          const ContactAccessibilityView(
            facilityId: 'colombo_sports_hub',
            facilityName: 'Colombo Sports Hub',
            phone: '+94 11 234 5678',
            email: 'info@colombosportshub.lk',
            address: 'Colombo 07',
            openingHours: '6AM - 10PM',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. CREATE
      // Select Accessibility Request type
      await tester.tap(find.text('Accessibility Request').first);
      await tester.pumpAndSettle();

      // Enter message
      await tester.enterText(
        find.byType(TextField),
        'Need wheelchair ramp assistance at entrance court 2',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      // Verify request created and appears in submissions list
      expect(
        find.text('Need wheelchair ramp assistance at entrance court 2'),
        findsOneWidget,
      );
      expect(appServices.contactRequestService.myRequests.length, equals(1));

      // 2. EDIT
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Updated request: need ramp assistance for court 1 & 2',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(
        find.text('Updated request: need ramp assistance for court 1 & 2'),
        findsOneWidget,
      );

      // 3. DELETE
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Delete request?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(appServices.contactRequestService.myRequests.isEmpty, isTrue);
      expect(
        find.text('No requests yet — submissions you create will appear here.'),
        findsOneWidget,
      );
    });
  });

  group('7. NotificationsView (Filter chips, Empty state, Back navigation)', () {
    testWidgets('renders notifications and filter chips filter correctly',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const NotificationsView()));
      await tester.pumpAndSettle();

      expect(find.text('Schedule Updated'), findsOneWidget);
      expect(find.text('Event Reminder'), findsOneWidget);

      // Filter by Events
      await tester.tap(find.widgetWithText(EventFilterChip, 'Events'));
      await tester.pumpAndSettle();
      expect(find.text('Event Reminder'), findsOneWidget);
      expect(find.text('Schedule Updated'), findsNothing);

      // Filter by Facilities
      await tester.tap(find.widgetWithText(EventFilterChip, 'Facilities'));
      await tester.pumpAndSettle();
      expect(find.text('Facility Update'), findsOneWidget);
    });

    testWidgets('back navigation works when pushed', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsView()),
              ),
              child: const Text('Open Notifications'),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsView), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsView), findsNothing);
    });
  });

  group('8. ProfileView (Settings switches, Navigation)', () {
    testWidgets('renders profile and settings switches toggle state',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.text('Saantha Sudarshana'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Contact & Accessibility'), findsOneWidget);

      // Switches
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      // Toggle dark mode switch
      await tester.tap(switches.last);
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(switches.last);
      expect(switchWidget.value, isTrue);
    });

    testWidgets('navigates to PersonalInformationView', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Personal Information'));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalInformationView), findsOneWidget);
      expect(find.text('SaSudarshana@email.com'), findsOneWidget);
    });

    testWidgets('navigates to ContactAccessibilityView', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contact & Accessibility'));
      await tester.pumpAndSettle();

      expect(find.byType(ContactAccessibilityView), findsOneWidget);
      expect(find.text('SportSpace Support & Facilities'), findsOneWidget);
    });

    testWidgets(
        'Payments chip is removed and Saved Events section shows and updates',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();

      // Check Payments chip is NOT present
      expect(find.text('Payments'), findsNothing);

      // Check Saved Events section is present
      expect(find.textContaining('Saved Events'), findsAtLeastNWidgets(1));
      expect(find.text('No saved events yet'), findsOneWidget);

      // Save an event
      appServices.bookmarkService.save('evt_badminton_open');
      await tester.pumpAndSettle();

      expect(find.text('Colombo Community Badminton Open'), findsOneWidget);
    });

    testWidgets('Profile search bar and filter chips filter settings',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();

      // Tap Preferences filter chip
      await tester.tap(find.widgetWithText(EventFilterChip, 'Preferences'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ProfileSettingTile, 'Notifications'), findsOneWidget);
      expect(find.text('Personal Information'), findsNothing);

      // Tap Preferences chip again to reset to All
      await tester.tap(find.widgetWithText(EventFilterChip, 'Preferences'));
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);

      // Test search bar
      await tester.enterText(find.byType(TextField), 'Dark');
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Personal Information'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Personal Information'), findsOneWidget);
    });
  });

  group('9. PersonalInformationView (Editing, Validation, Back navigation)', () {
    testWidgets('renders user info, edits details, and saves locally',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const PersonalInformationView()));
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Saantha Sudarshana'), findsAtLeastNWidgets(1));

      // Tap Edit
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Edit name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Saantha S. Perera');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Saantha S. Perera'), findsAtLeastNWidgets(1));
    });

    testWidgets('back navigation works', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationView(),
                ),
              ),
              child: const Text('Open Profile Info'),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Profile Info'));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalInformationView), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(PersonalInformationView), findsNothing);
    });
  });

  group('10. TertiaryPlaceholderView', () {
    testWidgets('renders placeholder view correctly', (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(
        _wrap(const TertiaryPlaceholderView(title: 'Sample Feature')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sample Feature'), findsOneWidget);
      expect(find.text('Sample Feature screen coming soon'), findsOneWidget);
    });
  });

  group('11. MyRequestsView & Multi-Screen Requests Integration', () {
    setUp(() {
      final existing = List.of(appServices.contactRequestService.myRequests);
      for (final r in existing) {
        appServices.contactRequestService.delete(r.id);
      }
    });

    testWidgets('HomeView quick navigation My Requests button navigates to MyRequestsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      final myRequestsBtn = find.text('My Requests');
      expect(myRequestsBtn, findsOneWidget);
      await tester.tap(myRequestsBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MyRequestsView), findsOneWidget);
    });

    testWidgets('EventsView quick navigation View requests button navigates to MyRequestsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      final viewRequestsBtn = find.text('View requests');
      expect(viewRequestsBtn, findsOneWidget);
      await tester.tap(viewRequestsBtn);
      await tester.pumpAndSettle();

      expect(find.byType(MyRequestsView), findsOneWidget);
    });

    testWidgets('EventsView My Requests filter chip navigates to MyRequestsView and reflects dynamic count',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      expect(find.text('My Requests'), findsOneWidget);

      // Create a request
      appServices.contactRequestService.create(
        facilityId: 'test_fac',
        type: ContactRequestType.accessibilityRequest,
        message: 'Need wheelchair ramp',
      );
      await tester.pumpAndSettle();

      expect(find.text('My Requests (1)'), findsOneWidget);
      expect(find.text('Need wheelchair ramp'), findsOneWidget);

      // Tap on the created request filter chip
      await tester.tap(find.text('Need wheelchair ramp'));
      await tester.pumpAndSettle();

      expect(find.byType(MyRequestsView), findsOneWidget);
      expect(find.text('Edit Request'), findsOneWidget);
      expect(find.text('Need wheelchair ramp'), findsAtLeastNWidgets(1));
    });

    testWidgets('MyRequestsView supports full create, edit, save, and delete lifecycle',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const MyRequestsView()));
      await tester.pumpAndSettle();

      expect(find.text('Contact Enquiry / Accessibility Request'), findsOneWidget);
      expect(find.text('No requests yet'), findsOneWidget);

      // Create
      await tester.enterText(
        find.widgetWithText(TextField, 'Describe your enquiry or accessibility needs...'),
        'Need special entrance assistance',
      );
      await tester.tap(find.text('Accessibility Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();

      expect(find.text('Request submitted successfully'), findsOneWidget);
      expect(find.text('Your Submissions (1)'), findsOneWidget);
      expect(find.text('Need special entrance assistance'), findsOneWidget);

      // Edit
      await tester.tap(find.byTooltip('Edit Request'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Request'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Describe your enquiry or accessibility needs...'),
        'Updated: Need special ramp assistance',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Request saved successfully'), findsOneWidget);
      expect(find.text('Updated: Need special ramp assistance'), findsOneWidget);

      // Delete
      await tester.tap(find.byTooltip('Delete Request'));
      await tester.pumpAndSettle();

      expect(find.text('Delete request?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('No requests yet'), findsOneWidget);
      expect(appServices.contactRequestService.myRequests, isEmpty);
    });
  });
}
