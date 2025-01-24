import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/ui/portion_control_app.dart';

void main() {
  testWidgets('HomePage has correct layout and placeholders',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PortionControlApp());

    // Verify if the app's title is displayed in the AppBar.
    expect(find.text('PortionControl'), findsOneWidget);

    // Verify the presence of the "Enter Your Details" text.
    expect(find.text('Enter Your Details'), findsOneWidget);

    // Verify that placeholders for body weight and food weight are visible.
    expect(
      find.byType(Placeholder),
      // 1 for the input rows and 1 for recommendation section.
      findsNWidgets(
        2,
      ),
    );

    // Verify the text next to the body weight input field (kg) and food weight
    // input field (g).
    expect(find.text('kg'), findsOneWidget);
    expect(find.text('g'), findsOneWidget);

    // Tap the Submit button (even though it's a placeholder).
    await tester.tap(find.byType(Placeholder).first);
    await tester.pump();

    // Verify that tapping the placeholder button doesn't cause errors (we can
    // extend this when it's implemented).
    // For now, there is no functionality, so this will simply pass if the
    // widget exists.
    expect(find.byType(Placeholder), findsNWidgets(2));

    // Check the visibility of the recommendation section placeholder.
    expect(find.byType(Placeholder), findsNWidgets(2));
  });
}
