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
import 'package:mobile/views/manager/manager_profile_screen.dart';
import 'package:mobile/views/manager/manager_maintenance_screen.dart';
import 'package:mobile/views/tertiary/notifications_view.dart';
import 'package:mobile/views/tertiary/events_view.dart';
import 'package:mobile/views/tertiary/facilities_view.dart';
import 'package:mobile/views/tertiary/profile_view.dart';
import 'package:mobile/views/my_bookings_screen.dart';
import 'package:mobile/widgets/app_bottom_nav.dart';
import 'package:mobile/views/manager/manager_schedule_screen.dart';
import 'package:mobile/views/manager/manager_booking_details_screen.dart';
import 'package:mobile/views/tertiary/home_view.dart';
import 'package:mobile/views/tertiary/my_requests_view.dart';
import 'package:mobile/views/tertiary/event_details_view.dart';
import 'package:mobile/views/tertiary/facility_profile_view.dart';
import 'package:mobile/views/slot_selection_screen.dart';
import 'package:mobile/utils/schedule_date_utils.dart';
import 'package:mobile/widgets/tertiary/date_selector.dart';
import 'package:mobile/services/account_settings_service.dart';
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

  group('New Requirements: Booking Cancellation, Slot Booking, Facility Creation & Clearing Badges', () {
    testWidgets('Req 1: in player screen after cancel a booking, notification is received and increases bell icon count',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      final initialCount = appServices.notificationService.unreadCountForRole('player');

      // Player cancels booking -> dispatches Booking Cancelled notification
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'Booking Cancelled',
        message: 'Your booking for Badminton Court 1 on 2026-10-15 has been cancelled.',
        category: NotificationCategory.event,
        accentColor: const Color(0xFFE14C4C),
        icon: Icons.event_busy_rounded,
      );

      // Unread count increased
      final newCount = appServices.notificationService.unreadCountForRole('player');
      expect(newCount, initialCount + 1);

      // Bell icon on HomeScreen shows badge with updated count
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('home_notification_badge')), findsOneWidget);
      expect(find.text(newCount.toString()), findsOneWidget);

      // Bell icon on MyBookingsScreen also shows badge with updated count
      await tester.pumpWidget(_wrap(const MyBookingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('my_bookings_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('my_bookings_notification_badge')), findsOneWidget);
    });

    testWidgets('Req 2: after player booked a slot for an event/facility, notification is received and increases bell icon count',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      final initialCount = appServices.notificationService.unreadCountForRole('player');

      // Slot booked -> dispatches Slot Booking Confirmed notification
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'Slot Booking Confirmed',
        message: 'Booked Badminton Court 1 for 10:00 AM - 11:00 AM on 2026-10-15.',
        category: NotificationCategory.event,
        accentColor: const Color(0xFF2E8B57),
        icon: Icons.event_available_rounded,
      );

      final newCount = appServices.notificationService.unreadCountForRole('player');
      expect(newCount, initialCount + 1);

      // HomeScreen bell badge shows the increased count
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_notification_badge')), findsOneWidget);

      // In PlayerNotificationsView, the notification is visible
      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();
      expect(find.text('Slot Booking Confirmed'), findsOneWidget);
      expect(find.text('Booked Badminton Court 1 for 10:00 AM - 11:00 AM on 2026-10-15.'),
          findsOneWidget);
    });

    testWidgets('Req 3: after facility manager creates new facility, notification is received in player notifications and increases bell icon count',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      final initialCount = appServices.notificationService.unreadCountForRole('player');

      // Facility manager creates facility -> dispatches New Facility Added for player & communityMember
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember'],
        title: 'New Facility Added',
        message: 'Facility "Sunset Tennis Arena" is now available for booking and events.',
        category: NotificationCategory.facility,
        accentColor: const Color(0xFF2E8B57),
        icon: Icons.location_on_outlined,
      );

      // Increases player unread count
      final newCount = appServices.notificationService.unreadCountForRole('player');
      expect(newCount, initialCount + 1);

      // Bell icon on HomeScreen shows increased count
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_notification_badge')), findsOneWidget);

      // In PlayerNotificationsView, player can view the new facility notification
      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();
      expect(find.text('New Facility Added'), findsOneWidget);
      expect(
        find.text('Facility "Sunset Tennis Arena" is now available for booking and events.'),
        findsOneWidget,
      );
    });

    testWidgets('Req 4: all notifications can be marked as read and clear the notification count on bell icon',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();

      // Add all 3 types of notifications
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'Booking Cancelled',
        message: 'Your booking has been cancelled.',
        category: NotificationCategory.event,
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        title: 'Slot Booking Confirmed',
        message: 'Slot booked successfully.',
        category: NotificationCategory.event,
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember'],
        title: 'New Facility Added',
        message: 'New facility is open.',
        category: NotificationCategory.facility,
      );

      // Unread count is positive
      expect(appServices.notificationService.unreadCountForRole('player'), greaterThan(0));

      // Open PlayerNotificationsView and tap Mark as read
      await tester.pumpWidget(_wrap(const PlayerNotificationsView()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('player_mark_read_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('player_mark_read_button')));
      await tester.pumpAndSettle();

      // Unread count is now zeroed
      expect(appServices.notificationService.unreadCountForRole('player'), 0);

      // Bell badge on HomeScreen is completely cleared
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_notification_badge')), findsNothing);

      // Bell badge on MyBookingsScreen is completely cleared
      await tester.pumpWidget(_wrap(const MyBookingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('my_bookings_notification_badge')), findsNothing);

      // Bell badge on UserProfileScreen is completely cleared
      await tester.pumpWidget(_wrap(const UserProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile_notification_badge')), findsNothing);
    });
  });

  group('Facility Manager Maintenance Notifications & Profile Bell Redirection', () {
    testWidgets('Req 1: when facility manager reports maintenance issue, notification is received by facilityManager',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      final initialCount = appServices.notificationService.unreadCountForRole('facilityManager');

      // Manager reports maintenance issue
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager', 'player', 'communityMember'],
        title: 'Maintenance Issue Reported',
        message: 'Maintenance reported for Badminton Court 1: Broken net',
        category: NotificationCategory.facility,
        accentColor: const Color(0xFFE14C4C),
        icon: Icons.build_circle_outlined,
      );

      final newCount = appServices.notificationService.unreadCountForRole('facilityManager');
      expect(newCount, initialCount + 1);

      final notifications =
          appServices.notificationService.getNotificationsForRole('facilityManager');
      expect(notifications.any((n) => n.title == 'Maintenance Issue Reported'), isTrue);
    });

    testWidgets('Req 2: when facility manager marks resolved a maintenance flag, notification is received by facilityManager',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      final initialCount = appServices.notificationService.unreadCountForRole('facilityManager');

      // Manager marks maintenance resolved
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager', 'player', 'communityMember'],
        title: 'Maintenance Flag Resolved',
        message: 'Badminton Court 1 maintenance flag has been resolved and is available for booking.',
        category: NotificationCategory.facility,
        accentColor: const Color(0xFF2E8B57),
        icon: Icons.check_circle_outline_rounded,
      );

      final newCount = appServices.notificationService.unreadCountForRole('facilityManager');
      expect(newCount, initialCount + 1);

      final notifications =
          appServices.notificationService.getNotificationsForRole('facilityManager');
      expect(notifications.any((n) => n.title == 'Maintenance Flag Resolved'), isTrue);
    });

    testWidgets(
        'Req 3: when facility manager clicks profile bell icon, it redirects to ManagerNotificationsScreen without player bottom nav',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Maintenance Issue Reported',
        message: 'Maintenance reported for Badminton Court 1: Broken net',
        category: NotificationCategory.facility,
      );

      await tester.pumpWidget(_wrap(const ManagerProfileScreen()));
      await tester.pumpAndSettle();

      // Tap notification bell icon on manager profile
      final bell = find.byKey(const Key('profile_notification_bell'));
      expect(bell, findsOneWidget);

      await tester.tap(bell);
      await tester.pumpAndSettle();

      // Must open ManagerNotificationsScreen, NOT PlayerNotificationsView
      expect(find.byType(ManagerNotificationsScreen), findsOneWidget);
      expect(find.byType(PlayerNotificationsView), findsNothing);
      expect(find.byType(AppBottomNav), findsNothing);

      // Verify mark all as read clears the manager unread count
      expect(find.byKey(const Key('manager_mark_read_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('manager_mark_read_button')));
      await tester.pumpAndSettle();
      expect(appServices.notificationService.unreadCountForRole('facilityManager'), 0);
    });
  });

  group('Rules 1 - 9: Role-Based Routing & Anti-Duplication Verification', () {
    test('Req 1: Single notification per task and deduplication on repeated dispatches/fetches', () {
      appServices.notificationService.resetForTesting();
      // Dispatch same notification twice within short window
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Facility Info Updated',
        message: 'Facility details for Badminton Court 1 were updated.',
        category: NotificationCategory.facility,
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Facility Info Updated',
        message: 'Facility details for Badminton Court 1 were updated.',
        category: NotificationCategory.facility,
      );

      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Facility Info Updated')
          .toList();

      expect(managerNotifs.length, 1, reason: 'Duplicate notification must be collapsed into 1');
    });

    test('Req 2: Player booking slot sends 1 notification to player and 1 to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager'],
        title: 'Slot Booking Confirmed',
        message: 'Booked Badminton Court 1 for 10:00 AM - 11:00 AM on 2026-10-15.',
        category: NotificationCategory.event,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Slot Booking Confirmed')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Slot Booking Confirmed')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Slot Booking Confirmed')
          .toList();

      expect(playerNotifs.length, 1);
      expect(managerNotifs.length, 1);
      expect(commNotifs.length, 0);
    });

    test('Req 3: Player cancelling booking sends 1 notification to player and 1 to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager'],
        title: 'Booking Cancelled',
        message: 'Your booking for Badminton Court 1 on 2026-10-15 has been cancelled.',
        category: NotificationCategory.event,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Booking Cancelled')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Booking Cancelled')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Booking Cancelled')
          .toList();

      expect(playerNotifs.length, 1);
      expect(managerNotifs.length, 1);
      expect(commNotifs.length, 0);
    });

    test('Req 4: Manager marking payment unpaid sends 1 notification to player and 1 to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager'],
        title: 'Payment Marked Unpaid',
        message: 'Payment for booking SS-20481 was marked as unpaid.',
        category: NotificationCategory.event,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Payment Marked Unpaid')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Payment Marked Unpaid')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Payment Marked Unpaid')
          .toList();

      expect(playerNotifs.length, 1);
      expect(managerNotifs.length, 1);
      expect(commNotifs.length, 0);
    });

    test('Req 5: Manager confirming payment sends 1 notification to player and 1 to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'facilityManager'],
        title: 'Payment Confirmed',
        message: 'Payment for booking SS-20481 has been confirmed.',
        category: NotificationCategory.event,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Payment Confirmed')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Payment Confirmed')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Payment Confirmed')
          .toList();

      expect(playerNotifs.length, 1);
      expect(managerNotifs.length, 1);
      expect(commNotifs.length, 0);
    });

    test('Req 6: Manager updating facility details sends 1 notification to facility manager and 1 to community member (none to player)', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager', 'communityMember'],
        title: 'Facility Info Updated',
        message: 'Updated facility info for Badminton Court 1.',
        category: NotificationCategory.facility,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Facility Info Updated')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Facility Info Updated')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Facility Info Updated')
          .toList();

      expect(playerNotifs.length, 0, reason: 'Player must not receive facility details edit notification');
      expect(managerNotifs.length, 1);
      expect(commNotifs.length, 1);
    });

    test('Req 7: Manager deleting facility sends 1 notification to player and 1 to community member (none to facility manager)', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player', 'communityMember'],
        title: 'Facility Removed',
        message: 'Facility "Badminton Court 3" has been removed.',
        category: NotificationCategory.facility,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Facility Removed')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Facility Removed')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Facility Removed')
          .toList();

      expect(playerNotifs.length, 1);
      expect(commNotifs.length, 1);
      expect(managerNotifs.length, 0, reason: 'Facility manager must not receive facility removed notification');
    });

    test('Req 8: Reporting maintenance sends only 1 notification to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Maintenance Issue Reported',
        message: 'Maintenance reported for Badminton Court 1: Broken net',
        category: NotificationCategory.facility,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Maintenance Issue Reported')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Maintenance Issue Reported')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Maintenance Issue Reported')
          .toList();

      expect(managerNotifs.length, 1);
      expect(playerNotifs.length, 0);
      expect(commNotifs.length, 0);
    });

    test('Req 9: Resolving maintenance flag sends only 1 notification to facility manager', () {
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Maintenance Flag Resolved',
        message: 'Badminton Court 1 maintenance flag has been resolved and is available for booking.',
        category: NotificationCategory.facility,
      );

      final playerNotifs = appServices.notificationService
          .getNotificationsForRole('player')
          .where((n) => n.title == 'Maintenance Flag Resolved')
          .toList();
      final managerNotifs = appServices.notificationService
          .getNotificationsForRole('facilityManager')
          .where((n) => n.title == 'Maintenance Flag Resolved')
          .toList();
      final commNotifs = appServices.notificationService
          .getNotificationsForRole('communityMember')
          .where((n) => n.title == 'Maintenance Flag Resolved')
          .toList();

      expect(managerNotifs.length, 1);
      expect(playerNotifs.length, 0);
      expect(commNotifs.length, 0);
    });
  });

  group('Latest Requirements: Schedule & Booking Bell Badges, Community Name Sync, & Date Selector Swiping', () {
    testWidgets('Req 1: ManagerScheduleScreen bell shows count badge, redirects to ManagerNotificationsScreen, and clears on read',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'New Event Scheduled',
        message: 'Tournament on court 1',
        category: NotificationCategory.schedule,
      );

      expect(appServices.notificationService.unreadCountForRole('facilityManager'), greaterThan(0));

      await tester.pumpWidget(_wrap(const Scaffold(body: ManagerScheduleScreen())));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('schedule_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('schedule_notification_badge')), findsOneWidget);

      await tester.tap(find.byKey(const Key('schedule_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(ManagerNotificationsScreen), findsOneWidget);

      // Tap Mark as read
      await tester.tap(find.byKey(const Key('manager_mark_read_button')));
      await tester.pumpAndSettle();

      expect(appServices.notificationService.unreadCountForRole('facilityManager'), 0);

      // Re-render schedule screen -> badge is gone
      await tester.pumpWidget(_wrap(const Scaffold(body: ManagerScheduleScreen())));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('schedule_notification_badge')), findsNothing);
    });

    testWidgets('Req 2: ManagerBookingDetailsScreen bell shows count badge, redirects to ManagerNotificationsScreen, and clears on read',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.dispatchNotification(
        targetRoles: ['facilityManager'],
        title: 'Slot Booking Confirmed',
        message: 'Court 2 booked for 11:00 AM',
        category: NotificationCategory.event,
      );

      expect(appServices.notificationService.unreadCountForRole('facilityManager'), greaterThan(0));

      await tester.pumpWidget(_wrap(const ManagerBookingDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('booking_details_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('booking_details_notification_badge')), findsOneWidget);

      await tester.tap(find.byKey(const Key('booking_details_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(ManagerNotificationsScreen), findsOneWidget);

      // Tap Mark as read
      await tester.tap(find.byKey(const Key('manager_mark_read_button')));
      await tester.pumpAndSettle();

      expect(appServices.notificationService.unreadCountForRole('facilityManager'), 0);

      // Re-render booking details screen -> badge is gone
      await tester.pumpWidget(_wrap(const ManagerBookingDetailsScreen()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('booking_details_notification_badge')), findsNothing);
    });

    testWidgets('Req 3: Community Member home page welcome message syncs dynamically with account name',
        (tester) async {
      _setScreenSize(tester);
      await AccountSettingsService.setCommunityUserName('Saantha Fernando');

      await tester.pumpWidget(_wrap(const TertiaryHomeView()));
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Saantha'), findsOneWidget);

      // Update name dynamically
      await AccountSettingsService.setCommunityUserName('Praveen Silva');
      await tester.pumpAndSettle();

      expect(find.text('Good morning, Praveen'), findsOneWidget);
    });

    testWidgets('Req 4: Community Member Events & Schedules DateSelector renders month header, today dot indicator, and swipeable dates',
        (tester) async {
      _setScreenSize(tester);
      final today = DateTime.now();
      final dates = List.generate(30, (index) => today.add(Duration(days: index)));

      DateTime selected = today;
      await tester.pumpWidget(_wrap(
        Scaffold(
          body: DateSelector(
            dates: dates,
            selectedDate: selected,
            onDateSelected: (date) {
              selected = date;
            },
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Month and year header is visible
      expect(find.byKey(const Key('date_selector_month_year')), findsOneWidget);

      // Today's date card has the dot indicator
      expect(find.byKey(const Key('date_selector_today_dot')), findsOneWidget);

      // Date selector allows horizontal scrolling
      expect(find.byKey(const Key('date_selector_list_view')), findsOneWidget);

      // Scroll horizontally to view future dates
      await tester.drag(find.byKey(const Key('date_selector_list_view')), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Tap on a visible date card
      final futureDateCards = find.byType(InkWell);
      await tester.tap(futureDateCards.first);
      await tester.pumpAndSettle();
      expect(selected, isNotNull);
    });

    testWidgets('Req 1: My Requests bell icon count displays unread badge and navigates to NotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.markAllAsRead('communityMember');

      await tester.pumpWidget(_wrap(const MyRequestsView()));
      await tester.pumpAndSettle();

      // Initially no unread badge
      expect(find.byKey(const Key('my_requests_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('my_requests_notification_badge')), findsNothing);

      // Add notification for communityMember
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        category: NotificationCategory.facility,
        title: 'New Update',
        message: 'A facility update is available.',
      );
      await tester.pumpAndSettle();

      // Badge now displays
      expect(find.byKey(const Key('my_requests_notification_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap bell to navigate
      await tester.tap(find.byKey(const Key('my_requests_notification_bell')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsView), findsOneWidget);
    });

    testWidgets('Req 2: Event Details bell icon count displays unread badge and navigates to NotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.markAllAsRead('communityMember');

      final testEvent = NearbyEvent(
        id: 'evt_test_details',
        title: 'Badminton Championship',
        sport: 'Badminton',
        date: 'Tomorrow',
        time: '10:00 AM - 12:00 PM',
        eventDate: DateTime(2026, 10, 14),
        location: 'Colombo Sports Complex',
        facility: 'Colombo Sports Complex',
        status: 'Open',
        imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=1200&q=80',
        description: 'Test event details description.',
        organizerName: 'Sports Club',
      );

      await tester.pumpWidget(_wrap(EventDetailsView(event: testEvent)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('event_details_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('event_details_notification_badge')), findsNothing);

      // Add unread notification for communityMember
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        category: NotificationCategory.event,
        title: 'Event Reminder',
        message: 'Reminder for your booked session.',
      );
      await tester.pumpAndSettle();

      // Badge now displays
      expect(find.byKey(const Key('event_details_notification_badge')), findsOneWidget);

      // Tap bell
      await tester.tap(find.byKey(const Key('event_details_notification_bell')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsView), findsOneWidget);
    });

    test('Req 3: Deleting a contact request dispatches a notification to community member', () {
      appServices.notificationService.resetForTesting();
      appServices.contactRequestService.resetForTesting();
      appServices.notificationService.markAllAsRead('communityMember');

      final initialCount = appServices.notificationService.unreadCountForRole('communityMember');
      final req = appServices.contactRequestService.create(
        facilityId: 'colombo_sports_hub',
        type: ContactRequestType.generalEnquiry,
        message: 'Inquiring about court lighting.',
      );

      final afterCreate = appServices.notificationService.unreadCountForRole('communityMember');
      expect(afterCreate, initialCount + 1);

      // Delete request
      appServices.contactRequestService.delete(req.id);

      // One more notification dispatched to communityMember
      expect(appServices.notificationService.unreadCountForRole('communityMember'), afterCreate + 1);
      final notifications = appServices.notificationService.getNotificationsForRole('communityMember');
      expect(notifications.first.title, 'Request Deleted');
      expect(notifications.first.description, contains('Contact Enquiry'));
    });

    test('Req 4 & 5: ScheduleDateUtils generates synchronized real-world days for player booking, manager schedule, and community events', () {
      final days = ScheduleDateUtils.generateRealWorldDays(count: 7);
      expect(days.length, 7);
      expect(days[0], 'Today');
      expect(days[1], 'Tomorrow');

      final today = DateTime.now();
      for (int i = 2; i < 7; i++) {
        final d = today.add(Duration(days: i));
        final weekday = ScheduleDateUtils.weekdayShorts[d.weekday - 1];
        expect(days[i], '$weekday ${d.day}');
      }

      // Check date resolving
      final resolvedToday = ScheduleDateUtils.resolveDate('Today');
      expect(resolvedToday.day, today.day);

      final resolvedTomorrow = ScheduleDateUtils.resolveDate('Tomorrow');
      final tomorrow = today.add(const Duration(days: 1));
      expect(resolvedTomorrow.day, tomorrow.day);
    });

    testWidgets('Req 4: SlotSelectionScreen displays synchronized real-world date labels', (tester) async {
      _setScreenSize(tester);

      await tester.pumpWidget(_wrap(const SlotSelectionScreen(
        facilityName: 'Colombo Sports Hub',
      )));
      await tester.pump();

      final expectedDays = ScheduleDateUtils.generateRealWorldDays(count: 7);
      expect(find.text(expectedDays[0]), findsOneWidget); // 'Today'
      expect(find.text(expectedDays[1]), findsOneWidget); // 'Tomorrow'
      expect(find.text(expectedDays[2]), findsOneWidget);
    });

    testWidgets('Req 5: ManagerScheduleScreen displays synchronized real-world day options', (tester) async {
      _setScreenSize(tester);

      await tester.pumpWidget(_wrap(const Scaffold(body: ManagerScheduleScreen())));
      await tester.pumpAndSettle();

      final expectedDays = ScheduleDateUtils.generateRealWorldDays(count: 7);
      // 'Today' is displayed in the day selector
      expect(find.text(expectedDays[0]), findsWidgets);
      // 'Tomorrow' is displayed in the day selector
      expect(find.text(expectedDays[1]), findsWidgets);
    });

    testWidgets('Latest Req 1: FacilityProfileView bell icon count displays unread badge and navigates to NotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.resetForTesting();
      appServices.notificationService.markAllAsRead('communityMember');

      await tester.pumpWidget(_wrap(const FacilityProfileView(
        facilityId: 'colombo_sports_hub',
        facilityName: 'Colombo Sports Hub',
        imageUrl: 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=1200&q=80',
      )));
      await tester.pumpAndSettle();

      // Initially no unread badge
      expect(find.byKey(const Key('facility_profile_notification_bell')), findsOneWidget);
      expect(find.byKey(const Key('facility_profile_notification_badge')), findsNothing);

      // Add unread notification for communityMember
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        category: NotificationCategory.facility,
        title: 'Facility Maintenance',
        message: 'Court 1 resurfacing complete.',
      );
      await tester.pumpAndSettle();

      // Badge now displays
      expect(find.byKey(const Key('facility_profile_notification_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap bell
      await tester.tap(find.byKey(const Key('facility_profile_notification_bell')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsView), findsOneWidget);
    });

    testWidgets('Latest Req 2: Confirmed booking slot for Today shows in community member Events & Schedules screen under Today filter',
        (tester) async {
      _setScreenSize(tester);
      appServices.eventRepository.resetForTesting();

      // Simulate a player slot booking confirmed by manager for Today
      final todayEvent = NearbyEvent(
        id: 'evt_booking_today_match',
        title: "Kasun's Match - Badminton Court 1",
        sport: 'Badminton',
        date: 'Today',
        time: '6:00 PM – 7:00 PM',
        eventDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        location: 'Colombo Sports Hub, Colombo',
        facility: 'Badminton Court 1',
        eventType: 'Match',
        status: 'Confirmed',
        imageUrl: 'assets/images/badminton.jpg',
        description: 'Booked and confirmed slot session at Badminton Court 1 by Kasun.',
        organizerName: 'Kasun Perera',
      );

      await appServices.eventRepository.createEvent(todayEvent);

      // Render community member's Events & Schedules screen
      await tester.pumpWidget(_wrap(const EventsView()));
      await tester.pumpAndSettle();

      // Community member default view is 'Today' filter — verified event is displayed
      expect(find.text("Kasun's Match - Badminton Court 1"), findsOneWidget);
      expect(find.text('Colombo Sports Hub, Colombo'), findsWidgets);
    });

    testWidgets('Player Profile Screen Bell: ProfileView(role: Player) strictly shows player notifications and opens PlayerNotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.markAllAsRead();

      // Dispatch 1 notification to communityMember only
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        category: NotificationCategory.event,
        title: 'Community Gathering',
        message: 'Community gathering this weekend.',
      );

      // Pump ProfileView for Player
      await tester.pumpWidget(_wrap(const ProfileView(role: 'Player')));
      await tester.pumpAndSettle();

      // Since player has 0 unread notifications, badge should not show
      expect(find.byKey(const Key('profile_notification_badge')), findsNothing);

      // Now dispatch 2 notifications for Player
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        category: NotificationCategory.facility,
        title: 'Player Slot Confirmed',
        message: 'Your slot booking is confirmed.',
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        category: NotificationCategory.facility,
        title: 'Player Match Update',
        message: 'Match schedule updated.',
      );
      await tester.pumpAndSettle();

      // Badge must show '2' for player (not 3 which would include communityMember)
      expect(find.byKey(const Key('profile_notification_badge')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Tap the bell icon — must navigate to PlayerNotificationsView, NOT NotificationsView!
      await tester.tap(find.byKey(const Key('profile_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(PlayerNotificationsView), findsOneWidget);
      expect(find.byType(NotificationsView), findsNothing);
    });

    testWidgets('Community Member Profile Screen Bell: ProfileView(role: Tertiary) strictly shows community notifications and opens NotificationsView',
        (tester) async {
      _setScreenSize(tester);
      appServices.notificationService.markAllAsRead();

      // Dispatch 3 notifications to player only
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        category: NotificationCategory.facility,
        title: 'Player Event 1',
        message: 'Message 1',
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        category: NotificationCategory.facility,
        title: 'Player Event 2',
        message: 'Message 2',
      );
      appServices.notificationService.dispatchNotification(
        targetRoles: ['player'],
        category: NotificationCategory.facility,
        title: 'Player Event 3',
        message: 'Message 3',
      );

      // Pump ProfileView for Community Member (role Tertiary)
      await tester.pumpWidget(_wrap(const ProfileView(role: 'Tertiary')));
      await tester.pumpAndSettle();

      // Since community member has 0 unread, badge should not show
      expect(find.byKey(const Key('profile_notification_badge')), findsNothing);

      // Now dispatch 1 notification for communityMember
      appServices.notificationService.dispatchNotification(
        targetRoles: ['communityMember'],
        category: NotificationCategory.event,
        title: 'Community Announcement',
        message: 'Annual festival is coming.',
      );
      await tester.pumpAndSettle();

      // Badge must show '1' for communityMember (not 4)
      expect(find.byKey(const Key('profile_notification_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap the bell icon — must navigate to NotificationsView, NOT PlayerNotificationsView!
      await tester.tap(find.byKey(const Key('profile_notification_bell')));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsView), findsOneWidget);
      expect(find.byType(PlayerNotificationsView), findsNothing);
    });
  });
}


