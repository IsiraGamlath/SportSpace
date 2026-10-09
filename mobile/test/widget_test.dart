import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/views/tertiary/home_view.dart';


void main() {
  testWidgets('Launch screen opens onboarding screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SportSpaceApp());

    expect(find.text('Find a place to play'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Find a place to play'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Slot Selection screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SportSpaceApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Find a place to play'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify header and court info are displayed
    expect(find.text('Select a Slot'), findsOneWidget);
    expect(find.text('Badminton Court 1'), findsOneWidget);
    expect(find.text('Colombo Sports Centre · Badminton'), findsOneWidget);

    // Verify slots and legend
    expect(find.text('Available'), findsAtLeastNWidgets(1));
    expect(find.text('Selected'), findsAtLeastNWidgets(1));
    expect(find.text('Booked'), findsAtLeastNWidgets(1));

    // Verify bottom bar
    expect(find.text('LKR 2,500'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Interactive conflict resolution flow works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SportSpaceApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Scroll to 7:00 PM and tap
    await tester.ensureVisible(find.text('7:00 PM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7:00 PM'));
    await tester.pumpAndSettle();

    // Verify Conflict Resolution sheet appears
    expect(find.text('Slot No Longer Available'), findsOneWidget);
    expect(find.text('Recommended Alternative'), findsOneWidget);
    expect(find.text('Select 7:30 PM Instead'), findsOneWidget);

    // Tap 'Select 7:30 PM Instead'
    await tester.tap(find.text('Select 7:30 PM Instead'));
    await tester.pumpAndSettle();

    // Verify sheet is closed and bottom bar reflects updated slot range
    expect(find.text('Slot No Longer Available'), findsNothing);
    expect(find.text('7:30 PM – 8:30 PM'), findsOneWidget);
  });

  testWidgets(
    'Tertiary Home screen renders correctly smoke test',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TertiaryHomeView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Good morning, Saantha'), findsOneWidget);
      expect(find.text('Ready to play?'), findsOneWidget);
      expect(
        find.text('Search facilities, sports or locations'),
        findsOneWidget,
      );
      expect(find.text('Popular Events'), findsOneWidget);
      expect(find.text('Nearby & Recommended'), findsOneWidget);
    },
  );
}
