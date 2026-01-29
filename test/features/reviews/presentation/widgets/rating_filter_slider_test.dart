import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/reviews/presentation/widgets/rating_filter_slider.dart';

void main() {
  group('RatingFilterSlider', () {
    testWidgets('should display "Any rating" when value is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Any rating'), findsOneWidget);
      expect(find.text('Minimum rating'), findsOneWidget);
    });

    testWidgets('should display "Any rating" when value is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: 0.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Any rating'), findsOneWidget);
    });

    testWidgets('should display "4.0+ stars" when value is 4.0',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: 4.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('4.0+ stars'), findsOneWidget);
    });

    testWidgets('should display "4.5+ stars" when value is 4.5',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: 4.5,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('4.5+ stars'), findsOneWidget);
    });

    testWidgets('should have a slider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should call onChanged with null when slider is set to 0',
        (tester) async {
      double? changedValue = 1.0; // Start with non-null to verify change

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: 3.0,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      // Find slider and drag to 0
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(-500, 0)); // Drag left to 0
      await tester.pumpAndSettle();

      // Should call onChanged with null (0 becomes null)
      expect(changedValue, isNull);
    });

    testWidgets('should call onChanged with value when slider is moved',
        (tester) async {
      double? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingFilterSlider(
              value: 0.0,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );

      // Find slider and drag to right
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(200, 0)); // Drag right
      await tester.pumpAndSettle();

      // Should have some positive value
      expect(changedValue, isNotNull);
      expect(changedValue! > 0, isTrue);
    });
  });
}
