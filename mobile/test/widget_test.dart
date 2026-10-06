import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Tertiary Home screen renders correctly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SportSpaceApp());

    // Verify key UI elements from the Tertiary Home screen
    expect(find.textContaining('Good morning, Saantha'), findsOneWidget);
    expect(find.text('Ready to play?'), findsOneWidget);
    expect(find.text('Search facilities, sports or locations'), findsOneWidget);
    expect(find.text('Popular Events'), findsOneWidget);
    expect(find.text('Nearby & Recommended'), findsOneWidget);
  });
}
