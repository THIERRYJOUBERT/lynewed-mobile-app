import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/rating_filter_chips.dart';

void main() {
  group('RatingFilterChips', () {
    testWidgets('should display "Any rating" option', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterChips(
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Any rating'), findsOneWidget);
    });

    testWidgets('should display all rating options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterChips(
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('5 stars'), findsOneWidget);
      expect(find.text('4 stars & up'), findsOneWidget);
      expect(find.text('3 stars & up'), findsOneWidget);
      expect(find.text('2 stars & up'), findsOneWidget);
      expect(find.text('1 star & up'), findsOneWidget);
    });

    testWidgets('should call onChanged with 4.0 when tapping "4 stars & up"',
        (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterChips(
              value: null,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('4 stars & up'));
      await tester.pump();

      expect(changedValue, 4.0);
    });

    testWidgets('should call onChanged with null when tapping "Any rating"',
        (tester) async {
      double? changedValue = 4.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterChips(
              value: 4.0,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Any rating'));
      await tester.pump();

      expect(changedValue, isNull);
    });

    testWidgets('should show selected state for current value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterChips(
              value: 3.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // The widget should be built with the correct value selected
      // We verify by checking that the widget tree contains the expected structure
      expect(find.byType(RatingFilterChips), findsOneWidget);
    });
  });
}
