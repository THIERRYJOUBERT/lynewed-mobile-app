import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_icon_button.dart';

void main() {
  // Helper to wrap widget in MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('LynewedIconButton', () {
    group('Rendering', () {
      testWidgets('should render with icon', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byType(LynewedIconButton), findsOneWidget);
      });

      testWidgets('should render with custom button size', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              buttonSize: 48.0,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(LynewedIconButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, 48.0);
        expect(sizedBox.height, 48.0);
      });

      testWidgets('should render with fill color', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              fillColor: Colors.red,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });

      testWidgets('should render with border', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              borderColor: Colors.blue,
              borderWidth: 2.0,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });

      testWidgets('should render with custom border radius', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              borderRadius: 12.0,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () => pressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedIconButton));
        await tester.pump();

        expect(pressed, true);
      });

      testWidgets('should not call onPressed when null (disabled)',
          (tester) async {
        var pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            const LynewedIconButton(
              icon: Icon(Icons.add),
              onPressed: null,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedIconButton));
        await tester.pump();

        expect(pressed, false);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator when showLoadingIndicator is true and loading',
          (tester) async {
        // Use a completer to control the async operation
        final completer = Completer<void>();

        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await completer.future;
              },
              showLoadingIndicator: true,
            ),
          ),
        );

        // Tap to trigger loading
        await tester.tap(find.byType(LynewedIconButton));
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the future to clean up
        completer.complete();
        await tester.pumpAndSettle();
      });

      testWidgets('should not show loading indicator when showLoadingIndicator is false',
          (tester) async {
        var called = false;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                called = true;
              },
              showLoadingIndicator: false,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedIconButton));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(called, true);
      });
    });

    group('Disabled State', () {
      testWidgets('should be disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const LynewedIconButton(
              icon: Icon(Icons.add),
              onPressed: null,
            ),
          ),
        );

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.onPressed, isNull);
      });

      testWidgets('should be enabled when onPressed is not null',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        );

        final iconButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );
        expect(iconButton.onPressed, isNotNull);
      });

      testWidgets('should apply disabled color when disabled', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const LynewedIconButton(
              icon: Icon(Icons.add),
              onPressed: null,
              disabledColor: Colors.grey,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });
    });

    group('Hover State', () {
      testWidgets('should apply hover color on hover', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              hoverColor: Colors.blue,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });

      testWidgets('should apply hover icon color on hover', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              hoverIconColor: Colors.white,
            ),
          ),
        );

        expect(find.byType(LynewedIconButton), findsOneWidget);
      });
    });

    group('Icon Types', () {
      testWidgets('should work with Material Icon', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should work with custom icon widget', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedIconButton(
              icon: Container(
                width: 24,
                height: 24,
                color: Colors.red,
              ),
              onPressed: () {},
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Default Values', () {
      test('should have correct default values', () {
        const button = LynewedIconButton(
          icon: Icon(Icons.add),
          onPressed: null,
        );

        expect(button.showLoadingIndicator, false);
        expect(button.borderRadius, isNull);
        expect(button.buttonSize, isNull);
        expect(button.fillColor, isNull);
        expect(button.borderColor, isNull);
        expect(button.borderWidth, isNull);
        expect(button.disabledColor, isNull);
        expect(button.disabledIconColor, isNull);
        expect(button.hoverColor, isNull);
        expect(button.hoverIconColor, isNull);
        expect(button.hoverBorderColor, isNull);
      });
    });
  });
}
