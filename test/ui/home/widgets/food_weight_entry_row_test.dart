import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portion_control/ui/home/widgets/food_weight_entry_row.dart';

import '../../../helpers/translate_test_helper.dart';

void main() {
  setUpAll(() async {
    await setUpFlutterTranslateForTests();
  });

  group('FoodWeightEntryRow Focus Tests', () {
    testWidgets('TextFormField gets focus when isEditState is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodWeightEntryRow(
              isEditState: true,
            ),
          ),
        ),
      );

      // Wait for the post-frame callback in initState.
      await tester.pump();

      final Finder textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      final FocusNode focusNode = tester
          .widget<TextField>(textFieldFinder)
          .focusNode!;
      expect(focusNode.hasFocus, isTrue, reason: 'TextField should have focus');
    });

    testWidgets('Focus moves to a new row when the Key changes', (
      WidgetTester tester,
    ) async {
      // 1. Build initial row.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                FoodWeightEntryRow(
                  key: ValueKey<String>('entry_0'),
                  isEditState: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      final Finder textField0Finder = find.byType(TextField);
      final FocusNode focusNode0 = tester
          .widget<TextField>(textField0Finder)
          .focusNode!;
      expect(focusNode0.hasFocus, isTrue);

      // 2. Simulate adding a new entry by rebuilding with a new Key for the
      // "new entry" row.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                const FoodWeightEntryRow(
                  key: ValueKey<String>('entry_0'),
                  isEditState: false,
                  value: '100',
                ),
                FoodWeightEntryRow(
                  key: const ValueKey<String>('entry_1'),
                  isEditState: true,
                  onSave: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      // Wait for rebuild and post-frame callbacks.
      await tester.pump();

      final Finder textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      final FocusNode fn0 = tester
          .widget<TextField>(textFields.at(0))
          .focusNode!;
      final FocusNode fn1 = tester
          .widget<TextField>(textFields.at(1))
          .focusNode!;

      expect(fn0.hasFocus, isFalse, reason: 'Old row should lose focus');
      expect(fn1.hasFocus, isTrue, reason: 'New row should gain focus');
    });
  });
}
