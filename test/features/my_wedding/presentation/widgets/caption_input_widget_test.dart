import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/design.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/widgets/caption_input_widget.dart';

void main() {
  group('CaptionInputWidget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildTestWidget({
      TextEditingController? testController,
      ValueChanged<String>? onChanged,
      String? label,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CaptionInputWidget(
              controller: testController ?? controller,
              onChanged: onChanged,
              label: label,
            ),
          ),
        ),
      );
    }

    group('Character Counter Display', () {
      testWidgets('displays character counter', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Should find the counter text
        expect(find.textContaining('/500'), findsOneWidget);
      });

      testWidgets('counter shows 0/500 initially', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('0/500'), findsOneWidget);
      });

      testWidgets('counter updates when typing', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Find the text field and enter text
        final textField = find.byType(TextFormField);
        await tester.enterText(textField, 'Hello');
        await tester.pump();

        expect(find.text('5/500'), findsOneWidget);
      });

      testWidgets('counter shows correct count with initial text',
          (tester) async {
        controller.text = 'Initial text here';
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('17/500'), findsOneWidget);
      });
    });

    group('Counter Color States', () {
      testWidgets('counter is gray when under 450 chars', (tester) async {
        controller.text = 'a' * 100;
        await tester.pumpWidget(buildTestWidget());

        final counterText = tester.widget<Text>(find.text('100/500'));
        final textStyle = counterText.style!;

        expect(textStyle.color, LynewedColors.textSecondary);
        expect(textStyle.fontWeight, FontWeight.normal);
      });

      testWidgets('counter is gray at exactly 449 chars', (tester) async {
        controller.text = 'a' * 449;
        await tester.pumpWidget(buildTestWidget());

        final counterText = tester.widget<Text>(find.text('449/500'));
        final textStyle = counterText.style!;

        expect(textStyle.color, LynewedColors.textSecondary);
        expect(textStyle.fontWeight, FontWeight.normal);
      });

      testWidgets('counter is orange when at 450 chars', (tester) async {
        controller.text = 'a' * 450;
        await tester.pumpWidget(buildTestWidget());

        final counterText = tester.widget<Text>(find.text('450/500'));
        final textStyle = counterText.style!;

        expect(textStyle.color, Colors.orange);
        expect(textStyle.fontWeight, FontWeight.w600);
      });

      testWidgets('counter is orange when at 499 chars', (tester) async {
        controller.text = 'a' * 499;
        await tester.pumpWidget(buildTestWidget());

        final counterText = tester.widget<Text>(find.text('499/500'));
        final textStyle = counterText.style!;

        expect(textStyle.color, Colors.orange);
        expect(textStyle.fontWeight, FontWeight.w600);
      });

      testWidgets('counter is red when at 500 chars', (tester) async {
        controller.text = 'a' * 500;
        await tester.pumpWidget(buildTestWidget());

        final counterText = tester.widget<Text>(find.text('500/500'));
        final textStyle = counterText.style!;

        expect(textStyle.color, LynewedColors.error);
        expect(textStyle.fontWeight, FontWeight.w600);
      });
    });

    group('Hint Text', () {
      testWidgets('displays hint text "Add a caption..."', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Add a caption...'), findsOneWidget);
      });
    });

    group('Optional Input', () {
      testWidgets('allows empty input (optional)', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Counter should show 0/500 for empty input
        expect(find.text('0/500'), findsOneWidget);

        // The widget should render without errors
        expect(find.byType(CaptionInputWidget), findsOneWidget);
      });

      testWidgets('empty input is valid for submission', (tester) async {
        String? capturedValue;
        await tester.pumpWidget(
          buildTestWidget(onChanged: (value) => capturedValue = value),
        );

        // Initial state - no onChanged called yet
        expect(controller.text, isEmpty);

        // Type and clear
        final textField = find.byType(TextFormField);
        await tester.enterText(textField, 'test');
        await tester.pump();
        expect(capturedValue, 'test');

        await tester.enterText(textField, '');
        await tester.pump();
        expect(capturedValue, '');
        expect(controller.text, isEmpty);
      });
    });

    group('Max Length Enforcement', () {
      testWidgets('prevents typing beyond 500 chars', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final textField = find.byType(TextFormField);

        // Try to enter 510 characters
        await tester.enterText(textField, 'a' * 510);
        await tester.pump();

        // Should be truncated to 500
        expect(controller.text.length, 500);
        expect(find.text('500/500'), findsOneWidget);
      });

      testWidgets('maxLength constant is 500', (tester) async {
        expect(CaptionInputWidget.maxLength, 500);
      });

      testWidgets('warningThreshold constant is 450', (tester) async {
        expect(CaptionInputWidget.warningThreshold, 450);
      });
    });

    group('Design System Integration', () {
      testWidgets('uses LynewedTextField', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(LynewedTextField), findsOneWidget);
      });

      testWidgets('enforces maxLength via controller', (tester) async {
        // Max length is enforced via the controller listener, not by passing
        // maxLength to LynewedTextField (to avoid the built-in counter)
        await tester.pumpWidget(buildTestWidget());

        final textField =
            tester.widget<LynewedTextField>(find.byType(LynewedTextField));
        // maxLength is NOT passed to LynewedTextField to hide built-in counter
        expect(textField.maxLength, isNull);

        // But max length is still enforced
        final formField = find.byType(TextFormField);
        await tester.enterText(formField, 'a' * 510);
        await tester.pump();

        expect(controller.text.length, CaptionInputWidget.maxLength);
      });

      testWidgets('passes controller to LynewedTextField', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final textField =
            tester.widget<LynewedTextField>(find.byType(LynewedTextField));
        expect(textField.controller, controller);
      });

      testWidgets('displays label when provided', (tester) async {
        await tester.pumpWidget(buildTestWidget(label: 'Caption (optional)'));

        expect(find.text('Caption (optional)'), findsOneWidget);
      });
    });

    group('onChanged Callback', () {
      testWidgets('calls onChanged when text changes', (tester) async {
        String? capturedValue;
        await tester.pumpWidget(
          buildTestWidget(onChanged: (value) => capturedValue = value),
        );

        final textField = find.byType(TextFormField);
        await tester.enterText(textField, 'My caption');
        await tester.pump();

        expect(capturedValue, 'My caption');
      });
    });

    group('Controller Listener Management', () {
      testWidgets('updates counter when controller text changes externally',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('0/500'), findsOneWidget);

        // Change controller text externally
        controller.text = 'External update';
        await tester.pump();

        expect(find.text('15/500'), findsOneWidget);
      });

      testWidgets('handles controller change via didUpdateWidget',
          (tester) async {
        // Start with first controller
        final controller1 = TextEditingController(text: 'First');
        await tester.pumpWidget(buildTestWidget(testController: controller1));
        expect(find.text('5/500'), findsOneWidget);

        // Change to second controller with different text
        final controller2 = TextEditingController(text: 'Second controller');
        await tester.pumpWidget(buildTestWidget(testController: controller2));
        expect(find.text('17/500'), findsOneWidget);

        // Verify the new controller is being listened to
        controller2.text = 'Updated';
        await tester.pump();
        expect(find.text('7/500'), findsOneWidget);

        // Clean up
        controller1.dispose();
        controller2.dispose();
      });
    });
  });
}
