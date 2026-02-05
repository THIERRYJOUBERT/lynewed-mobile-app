import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_button.dart';
import 'package:lynewed_beta/core/design/lynewed_colors.dart';

void main() {
  // Helper to wrap widget in MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('LynewedButton', () {
    group('Rendering', () {
      testWidgets('should render with text', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(LynewedButton), findsOneWidget);
      });

      testWidgets('should render with icon', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'With Icon',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('With Icon'), findsOneWidget);
      });

      testWidgets('should render with custom width', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Full Width',
              onPressed: () {},
              width: 300.0,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, 300.0);
      });
    });

    group('Callbacks', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Press Me',
              onPressed: () => pressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedButton));
        await tester.pump();

        expect(pressed, true);
      });

      testWidgets('should not call onPressed when null (disabled)',
          (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            const LynewedButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedButton));
        await tester.pump();

        expect(pressed, false);
      });
    });

    group('Button Types', () {
      testWidgets('should render primary button with ElevatedButton',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Primary',
              onPressed: () {},
              type: LynewedButtonType.primary,
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should render secondary button with OutlinedButton',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Secondary',
              onPressed: () {},
              type: LynewedButtonType.secondary,
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('should render ghost button with TextButton', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Ghost',
              onPressed: () {},
              type: LynewedButtonType.ghost,
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('should render destructive button with TextButton',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Delete',
              onPressed: () {},
              type: LynewedButtonType.destructive,
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('should render destructiveFilled button with ElevatedButton',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Confirm Delete',
              onPressed: () {},
              type: LynewedButtonType.destructiveFilled,
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Text should not be visible during loading
        expect(find.text('Loading'), findsNothing);
      });

      testWidgets('should show text when isLoading is false', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Not Loading',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Not Loading'), findsOneWidget);
      });

      testWidgets(
          'loading indicator should have correct color for primary button',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
              type: LynewedButtonType.primary,
            ),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        final animation =
            indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, Colors.white);
      });

      testWidgets(
          'loading indicator should have correct color for secondary button',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
              type: LynewedButtonType.secondary,
            ),
          ),
        );

        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        final animation =
            indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, LynewedColors.primary);
      });
    });

    group('Disabled State', () {
      testWidgets('should be disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const LynewedButton(
              text: 'Disabled',
              onPressed: null,
              type: LynewedButtonType.primary,
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('should be enabled when onPressed is not null',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Enabled',
              onPressed: () {},
              type: LynewedButtonType.primary,
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('Button Height', () {
      testWidgets('should have correct height', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        );

        // Find SizedBox that wraps the button
        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.height, 48.0); // LynewedSpacing.buttonHeight
      });
    });

    group('Enum Values', () {
      test('LynewedButtonType should have all expected values', () {
        expect(LynewedButtonType.values.length, 6);
        expect(LynewedButtonType.values, contains(LynewedButtonType.primary));
        expect(LynewedButtonType.values, contains(LynewedButtonType.secondary));
        expect(LynewedButtonType.values, contains(LynewedButtonType.ghost));
        expect(
            LynewedButtonType.values, contains(LynewedButtonType.destructive));
        expect(LynewedButtonType.values,
            contains(LynewedButtonType.destructiveFilled));
        expect(LynewedButtonType.values,
            contains(LynewedButtonType.destructiveOutlined));
      });
    });
  });
}
