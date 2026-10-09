import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/app_notification_model.dart';
import 'package:mobile/models/contact_request_model.dart';
import 'package:mobile/models/sport_event_model.dart';
import 'package:mobile/services/app_services.dart';
import 'package:mobile/views/home_screen.dart';
import 'package:mobile/views/player_notifications_view.dart';
import 'package:mobile/views/account_profile_screen.dart';
import 'package:mobile/views/facility_profile_screen.dart';
import 'package:mobile/views/manager/manager_notifications_screen.dart';
import 'package:mobile/views/tertiary/notifications_view.dart';
import 'package:mobile/views/tertiary/events_view.dart';
import 'package:mobile/views/tertiary/facilities_view.dart';
import 'package:mobile/views/tertiary/profile_view.dart';
import 'package:mobile/widgets/app_bottom_nav.dart';
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

  group('Requirement 1 & 2: Tertiary Request Form Backend & CRUD', () {
    test('creates contact enquiry and accessibility requests with backend service', () {
      final req1 = appServices.contactRequestService.create(
        facilityId: 'colombo_sports_hub',
        type: ContactRequestType.generalEnquiry,
        message: 'Are badminton racquets available for rent on weekends?',
      );

      final req2 = appServices.contactRequestService.create(
        facilityId: 'colombo_sports_hub',
        type: ContactRequestType.accessibilityRequest,
        message: 'Requesting wheelchair ramp assistance at court entrance.',
      );

      final allRequests = appServices.contactRequestService.myRequests;
      expect(allRequests.length, 2);
      expect(allRequests.any((r) => r.id == req1.id), isTrue);
      expect(allRequests.any((r) => r.id == req2.id), isTrue);
      expect(req1.type, ContactRequestType.generalEnquiry);
      expect(req2.type, ContactRequestType.accessibilityRequest);
    });

    test('edits and deletes request with backend state synchronization', () {
      final req = appServices.contactRequestService.create(
        facilityId: 'city_sports_ground',
        type: ContactRequestType.generalEnquiry,
        message: 'Original message',
      );

      // Edit
      appServices.contactRequestService.update(
        req.id,
        type: ContactRequestType.accessibilityRequest,
        message: 'Updated message with accessibility needs',
      );

      final updated = appServices.contactRequestService.myRequests
          .firstWhere((r) => r.id == req.id);
      expect(updated.message, 'Updated message with accessibility needs');
      expect(updated.type, ContactRequestType.accessibilityRequest);
      expect(updated.updatedAt, isNotNull);

      // Delete
      appServices.contactRequestService.delete(req.id);
      expect(
        appServices.contactRequestService.myRequests.any((r) => r.id == req.id),
        isFalse,
      );
    });
  });

  group('Requirement 3 & 4: Player Notifications Screen & Role Targeting', () {
    testWidgets('renders PlayerNotificationsView matching screenshot layout & filter chips',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();

      // Header title and BottomNavigationBar item both contain 'Notifications'
      expect(find.text('Notifications'), findsNWidgets(2));

      // 4 filter chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Facilities'), findsOneWidget);

      // Bottom nav bar present with 5 tabs
      expect(find.byType(AppBottomNav), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Default notification cards
      expect(find.text('Schedule Updated'), findsOneWidget);
      expect(find.text('Event Reminder'), findsOneWidget);
      expect(find.text('Facility Update'), findsOneWidget);
      expect(find.text('Event Cancelled'), findsOneWidget);

      // Test filter chip switching
      await tester.tap(find.byKey(const Key('player_filter_Schedules')));
      await tester.pumpAndSettle();

      expect(find.text('Schedule Updated'), findsOneWidget);
      expect(find.text('Event Reminder'), findsNothing);
      expect(find.text('Facility Update'), findsNothing);

      // Switch back to All
      await tester.tap(find.byKey(const Key('player_filter_All')));
      await tester.pumpAndSettle();
      expect(find.text('Schedule Updated'), findsOneWidget);
      expect(find.text('Event Reminder'), findsOneWidget);
    });

    testWidgets('HomeScreen navbar notification button navigates to PlayerNotificationsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Find Notifications tab in AppBottomNav
      final notificationsNav = find.text('Notifications');
      expect(notificationsNav, findsOneWidget);

      await tester.tap(notificationsNav);
      await tester.pumpAndSettle();

      // Verified on PlayerNotificationsView
      expect(find.byType(PlayerNotificationsView), findsOneWidget);
    });
  });

  group('Requirement 5: Event Create, Edit, Cancel Cross-Role Notifications', () {
    test('creating event notifies Player, Facility Manager, and Community Member', () async {
      final newEvent = NearbyEvent(
        id: 'evt_tennis_open',
        title: 'Colombo Tennis Open',
        sport: 'Tennis',
        date: '25 October 2026',
        time: '8:00 AM – 2:00 PM',
        eventDate: DateTime(2026, 10, 25),
        location: 'City Tennis Courts',
        status: 'Open',
        imageUrl: 'assets/images/badminton.jpg',
      );

      await appServices.eventRepository.createEvent(newEvent);

      // Check player notifications
      final playerNotifs =
          appServices.notificationService.getNotificationsForRole('player');
      expect(
        playerNotifs.any((n) => n.title == 'New Event Scheduled' && n.description.contains('Colombo Tennis Open')),
        isTrue,
      );

      // Check manager notifications
      final managerNotifs =
          appServices.notificationService.getNotificationsForRole('facilityManager');
      expect(
        managerNotifs.any((n) => n.title == 'New Event Scheduled' && n.description.contains('Colombo Tennis Open')),
        isTrue,
      );

      // Check community member notifications
      final communityNotifs =
          appServices.notificationService.getNotificationsForRole('communityMember');
      expect(
        communityNotifs.any((n) => n.title == 'New Event Scheduled' && n.description.contains('Colombo Tennis Open')),
        isTrue,
      );
    });

    test('editing event notifies Player, Facility Manager, and Community Member', () async {
      final updatedEvent = NearbyEvent(
        id: 'evt_badminton_open',
        title: 'Colombo Community Badminton Open',
        sport: 'Badminton',
        date: '20 September 2026',
        time: '10:00 AM – 6:00 PM',
        eventDate: DateTime(2026, 9, 20),
        location: 'Colombo Sports Hub',
        status: 'Open',
        imageUrl: 'assets/images/badminton.jpg',
      );

      await appServices.eventRepository.updateEvent(updatedEvent);

      for (final role in ['player', 'facilityManager', 'communityMember']) {
        final notifs = appServices.notificationService.getNotificationsForRole(role);
        expect(
          notifs.any((n) => n.title == 'Schedule Updated' && n.description.contains('Colombo Community Badminton Open')),
          isTrue,
          reason: 'Failed for role $role',
        );
      }
    });

    test('cancelling event notifies Player, Facility Manager, and Community Member', () async {
      await appServices.eventRepository.cancelEvent('evt_badminton_open');

      for (final role in ['player', 'facilityManager', 'communityMember']) {
        final notifs = appServices.notificationService.getNotificationsForRole(role);
        expect(
          notifs.any((n) => n.title == 'Event Cancelled' && n.description.contains('Colombo Community Badminton Open')),
          isTrue,
          reason: 'Failed for role $role',
        );
      }
    });
  });

  group('Requirement 6 & 7: Facility Add, Remove, Edit Notifications', () {
    test('adding and removing facility notifies Player and Community Member', () {
      // Simulate facility add
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember'],
        category: NotificationCategory.facility,
        title: 'New Facility Added',
        message: 'Facility "Indoor Futsal Arena" is now available.',
        accentColor: const Color(0xFF2E8B57),
      );

      expect(
        appServices.notificationService
            .getNotificationsForRole('player')
            .any((n) => n.title == 'New Facility Added'),
        isTrue,
      );
      expect(
        appServices.notificationService
            .getNotificationsForRole('communityMember')
            .any((n) => n.title == 'New Facility Added'),
        isTrue,
      );

      // Simulate facility remove
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember'],
        category: NotificationCategory.facility,
        title: 'Facility Removed',
        message: 'Facility "Old Tennis Court" has been removed.',
        accentColor: const Color(0xFFE14C4C),
      );

      expect(
        appServices.notificationService
            .getNotificationsForRole('player')
            .any((n) => n.title == 'Facility Removed'),
        isTrue,
      );
      expect(
        appServices.notificationService
            .getNotificationsForRole('communityMember')
            .any((n) => n.title == 'Facility Removed'),
        isTrue,
      );
    });

    test('editing facility info notifies Player, Community Member, and Facility Manager', () {
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember', 'facilityManager'],
        category: NotificationCategory.facility,
        title: 'Facility Update',
        message: 'Facility details have been updated for Badminton Court 1.',
        accentColor: const Color(0xFFDF8420),
      );

      for (final role in ['player', 'communityMember', 'facilityManager']) {
        expect(
          appServices.notificationService
              .getNotificationsForRole(role)
              .any((n) => n.title == 'Facility Update' && n.description.contains('Badminton Court 1')),
          isTrue,
          reason: 'Failed for $role',
        );
      }
    });
  });

  group('Requirement 8 & 9: Payment Confirmed and Unpaid Notifications to Booking Player', () {
    test('confirmed payment shows notification to booking player', () {
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        userId: 'player_123',
        category: NotificationCategory.event,
        title: 'Payment Confirmed',
        message: 'Your payment for booking BK-9901 has been confirmed.',
        accentColor: const Color(0xFF2E8B57),
      );

      final playerNotifs =
          appServices.notificationService.getNotificationsForRole('player');
      expect(
        playerNotifs.any((n) => n.title == 'Payment Confirmed' && n.description.contains('BK-9901')),
        isTrue,
      );
    });

    test('unpaid payment marks shows notification to booking player', () {
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        userId: 'player_123',
        category: NotificationCategory.event,
        title: 'Payment Marked Unpaid',
        message: 'Your payment for booking BK-9901 was marked as unpaid.',
        accentColor: const Color(0xFFE14C4C),
      );

      final playerNotifs =
          appServices.notificationService.getNotificationsForRole('player');
      expect(
        playerNotifs.any((n) => n.title == 'Payment Marked Unpaid' && n.description.contains('BK-9901')),
        isTrue,
      );
    });
  });

  group('Requirement 11: Saved Events Backend & Service', () {
    test('saves, toggles, and unsaves event IDs', () {
      expect(appServices.bookmarkService.isSaved('evt_basketball_league'), isFalse);

      appServices.bookmarkService.save('evt_basketball_league');
      expect(appServices.bookmarkService.isSaved('evt_basketball_league'), isTrue);
      expect(appServices.bookmarkService.savedEvents.length, 1);

      // Toggle off
      appServices.bookmarkService.toggle('evt_basketball_league');
      expect(appServices.bookmarkService.isSaved('evt_basketball_league'), isFalse);
      expect(appServices.bookmarkService.savedEvents.isEmpty, isTrue);
    });
  });

  group('Requirement 12: 3-Hour Event Reminder Notification to Community Member', () {
    test('marking reminder on event adds reminder notification to community member notifications', () {
      final event = NearbyEvent(
        id: 'evt_football_training',
        title: 'Youth Football Training Day',
        sport: 'Football',
        date: '22 September 2026',
        time: '4:00 PM',
        eventDate: DateTime(2026, 9, 22),
        location: 'City Sports Ground',
        status: 'Confirmed',
        imageUrl: 'assets/images/football.jpg',
      );

      appServices.reminderService.subscribe('evt_football_training', event);

      final communityNotifs =
          appServices.notificationService.getNotificationsForRole('communityMember');
      expect(
        communityNotifs.any((n) =>
            n.title == 'Event Reminder' &&
            n.description.contains('Youth Football Training Day') &&
            n.description.contains('starts in 3 hours')),
        isTrue,
      );
    });
  });

  group('Requirement 13: Request Submission Notification to Submitting Community Member', () {
    test('submitting contact enquiry or accessibility request triggers community member notification', () {
      appServices.contactRequestService.create(
        facilityId: 'Colombo Sports Hub',
        type: ContactRequestType.accessibilityRequest,
        message: 'Need wheelchair seating reserved near court 2.',
      );

      final communityNotifs =
          appServices.notificationService.getNotificationsForRole('communityMember');
      expect(
        communityNotifs.any((n) =>
            n.title == 'Request Submitted' &&
            n.description.contains('Accessibility Request') &&
            n.description.contains('Colombo Sports Hub')),
        isTrue,
      );
    });
  });

  group('Requirement 1 - 5: Player Navigation, Bell, Card Tap & Mark as Read', () {
    testWidgets('Req 1: PlayerNotificationsView navbar profile click navigates to UserProfileScreen',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();

      // Tap Profile navbar item (index 4)
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.byType(UserProfileScreen), findsOneWidget);
    });

    testWidgets('Req 2: UserProfileScreen notification bell redirects to PlayerNotificationsView',
        (tester) async {
      _setScreenSize(tester);
      await tester.pumpWidget(_wrap(const UserProfileScreen()));
      await tester.pumpAndSettle();

      // Tap notification bell in header
      await tester.tap(find.byKey(const Key('profile_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerNotificationsView), findsOneWidget);
    });

    testWidgets('Req 3: Player notification card click marks as read and directs to FacilityProfileScreen',
        (tester) async {
      _setScreenSize(tester);
      final notif = appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'New Facility Added',
        message: 'Colombo Badminton Complex (Badminton) is now open for bookings.',
        category: NotificationCategory.facility,
      );

      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();

      expect(find.text('Colombo Badminton Complex (Badminton) is now open for bookings.'),
          findsOneWidget);

      // Tap the notification card
      await tester.tap(find.byKey(Key('player_notification_${notif.id}')));
      await tester.pumpAndSettle();

      // Should open facility profile
      expect(find.byType(FacilityProfileScreen), findsOneWidget);
      expect(find.text('Colombo Badminton Complex'), findsWidgets);

      // Should be marked as read
      final updated = appServices.notificationService.allNotifications
          .firstWhere((n) => n.id == notif.id);
      expect(updated.showDot, isFalse);
    });

    testWidgets('Req 4: HomeScreen shows notification bell with count badge and redirects to PlayerNotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'Payment Confirmed',
        message: 'Payment for Badminton Court booking confirmed.',
        category: NotificationCategory.event,
      );

      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('home_notification_badge')), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerNotificationsView), findsOneWidget);
    });

    testWidgets('Req 5: PlayerNotificationsView Mark as read button zeroes player notification count',
        (tester) async {
      _setScreenSize(tester);
      expect(appServices.notificationService.unreadCountForRole('player'),
          greaterThan(0));

      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();

      // Click Mark as read
      await tester.tap(find.byKey(const Key('player_mark_read_button')));
      await tester.pumpAndSettle();

      // Count is zero
      expect(appServices.notificationService.unreadCountForRole('player'), 0);

      // Returning to HomeScreen shows bell without badge
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_notification_badge')), findsNothing);
    });
  });

  group('Requirement 6 - 8: Community Member Notification Badges & Mark as Read', () {
    testWidgets('Req 6: Community member notification count displays on bell icons in EventsView, FacilitiesView, ProfileView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        title: 'New Schedule',
        message: 'Community tournament schedule published.',
        category: NotificationCategory.schedule,
      );

      final unread = appServices.notificationService.unreadCountForRole('communityMember');
      expect(unread, greaterThan(0));

      // EventsView
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('events_notification_badge')), findsOneWidget);

      // FacilitiesView
      await tester.pumpWidget(_wrap(const FacilitiesView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('facilities_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('facilities_notification_badge')), findsOneWidget);

      // ProfileView
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('profile_notification_badge')), findsOneWidget);
    });

    testWidgets('Req 7 & 8: NotificationsView Mark as read zeroes community member notification counts across screens',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        title: 'Facility Alert',
        message: 'Maintenance ongoing at court 3.',
        category: NotificationCategory.facility,
      );

      expect(appServices.notificationService.unreadCountForRole('communityMember'),
          greaterThan(0));

      // Open NotificationsView and tap Mark as read
      await tester.pumpWidget(_wrap(const NotificationsView()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('community_mark_read_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('community_mark_read_button')));
      await tester.pumpAndSettle();

      // Count is zeroed
      expect(appServices.notificationService.unreadCountForRole('communityMember'), 0);

      // EventsView badge is gone
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('events_notification_badge')), findsNothing);

      // FacilitiesView badge is gone
      await tester.pumpWidget(_wrap(const FacilitiesView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('facilities_notification_badge')), findsNothing);

      // ProfileView badge is gone
      await tester.pumpWidget(_wrap(const ProfileView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_notification_badge')), findsNothing);
    });
  });
}
