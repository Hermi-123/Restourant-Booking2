import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restaurant/main.dart';

void main() {
  testWidgets('App landing test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartDineApp());

    // Verify that our app name exists.
    expect(find.text('Smart Dine'), findsOneWidget);
    expect(find.text('Step in, scan your table, and start the feast.'), findsOneWidget);
  });
}
