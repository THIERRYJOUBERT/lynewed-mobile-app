/// Tests for InviteCodeInput widget.
///
/// Verifies the code input field for wedding invitation codes:
/// - Uppercase conversion
/// - Character limit
/// - Helper text display
/// - Error state
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/invite_code_input.dart';

void main() {
  group('InviteCodeInput', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildTestWidget({
      String? errorText,
      bool enabled = true,
      ValueChanged<String>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: InviteCodeInput(
              controller: controller,
              errorText: errorText,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display text field', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should display placeholder hint', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('_ _ _ _ _ _ _ _'), findsOneWidget);
      });

      testWidgets('should display character count helper when empty',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('8 characters required (0/8)'), findsOneWidget);
      });
    });

    group('Character conversion', () {
      testWidgets('should convert lowercase to uppercase', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.enterText(find.byType(TextField), 'abcd');
        await tester.pump();

        // Assert
        expect(controller.text, 'ABCD');
      });

      testWidgets('should accept mixed case and convert', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.enterText(find.byType(TextField), 'AbCd1234');
        await tester.pump();

        // Assert
        expect(controller.text, 'ABCD1234');
      });

      testWidgets('should only accept alphanumeric characters', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.enterText(find.byType(TextField), 'AB-CD_12!@34');
        await tester.pump();

        // Assert - only alphanumeric should be kept
        expect(controller.text, 'ABCD1234');
      });
    });

    group('Character limit', () {
      testWidgets('should limit input to 8 characters', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.enterText(find.byType(TextField), 'ABCDEFGHIJ');
        await tester.pump();

        // Assert - only first 8 characters
        expect(controller.text, 'ABCDEFGH');
      });

      testWidgets('should not show counter text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - no default counter (0/8 format from Flutter)
        // Our custom helper shows "(X/8)" in a different style
        expect(find.text('0/8'), findsNothing);
      });
    });

    group('Helper text', () {
      testWidgets('should show character count when incomplete', (tester) async {
        // Arrange - pre-set the controller before building
        controller.text = 'ABC';
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('8 characters required (3/8)'), findsOneWidget);
      });

      testWidgets('should show success when complete', (tester) async {
        // Arrange - pre-set the controller before building
        controller.text = 'ABCD1234';
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Code complete ✓'), findsOneWidget);
      });
    });

    group('Error state', () {
      testWidgets('should display error text when provided', (tester) async {
        // Arrange & Act
        await tester
            .pumpWidget(buildTestWidget(errorText: 'Invalid or expired code'));

        // Assert
        expect(find.text('Invalid or expired code'), findsOneWidget);
      });

      testWidgets('error text should replace helper text', (tester) async {
        // Arrange & Act
        controller.text = 'ABC';
        await tester
            .pumpWidget(buildTestWidget(errorText: 'Invalid or expired code'));

        // Assert - error shown, not helper
        expect(find.text('Invalid or expired code'), findsOneWidget);
        expect(find.textContaining('8 characters required'), findsNothing);
      });
    });

    group('Enabled state', () {
      testWidgets('should be editable when enabled', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(enabled: true));

        // Act & Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isTrue);
      });

      testWidgets('should not be editable when disabled', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(enabled: false));

        // Act & Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });
    });

    group('Callback', () {
      testWidgets('should call onChanged when text changes', (tester) async {
        // Arrange
        String? changedValue;
        await tester.pumpWidget(buildTestWidget(
          onChanged: (value) => changedValue = value,
        ));

        // Act
        await tester.enterText(find.byType(TextField), 'ABCD');
        await tester.pump();

        // Assert
        expect(changedValue, 'ABCD');
      });
    });

    group('Styling', () {
      testWidgets('should center text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.textAlign, TextAlign.center);
      });

      testWidgets('should have letter spacing for readability', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style?.letterSpacing, 8);
      });
    });
  });
}
