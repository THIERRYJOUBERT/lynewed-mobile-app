import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_text_field.dart';

void main() {
  // Helper to wrap widget in MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }

  group('LynewedTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Rendering', () {
      testWidgets('should render with label', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              label: 'Email',
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.byType(LynewedTextField), findsOneWidget);
      });

      testWidgets('should render with hint', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              hint: 'Enter your email',
            ),
          ),
        );

        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('should render with both label and hint', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              label: 'Email',
              hint: 'Enter your email',
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('should render without label', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should render with prefix icon', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
        );

        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('should render with suffix icon', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              suffixIcon: const Icon(Icons.clear),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });

    group('Text Input', () {
      testWidgets('should call onChanged when text changes', (tester) async {
        String? changedValue;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              label: 'Name',
              onChanged: (value) => changedValue = value,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Test Name');
        await tester.pump();

        expect(changedValue, 'Test Name');
      });

      testWidgets('should update controller value when text is entered',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              label: 'Name',
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Test Value');
        await tester.pump();

        expect(controller.text, 'Test Value');
      });

      testWidgets('should display initial controller value', (tester) async {
        controller.text = 'Initial Value';

        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              label: 'Name',
            ),
          ),
        );

        expect(find.text('Initial Value'), findsOneWidget);
      });
    });

    group('Validation', () {
      testWidgets('should show validation error when validator returns error',
          (tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildTestWidget(
            Form(
              key: formKey,
              child: LynewedTextField(
                controller: controller,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Trigger validation
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should not show error when validation passes',
          (tester) async {
        final formKey = GlobalKey<FormState>();
        controller.text = 'test@example.com';

        await tester.pumpWidget(
          buildTestWidget(
            Form(
              key: formKey,
              child: LynewedTextField(
                controller: controller,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Trigger validation
        final isValid = formKey.currentState!.validate();
        await tester.pump();

        expect(isValid, true);
        expect(find.text('Email is required'), findsNothing);
      });
    });

    group('Enabled/Disabled States', () {
      testWidgets('should be enabled by default', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
            ),
          ),
        );

        final textField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        expect(textField.enabled, true);
      });

      testWidgets('should be disabled when enabled is false', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              enabled: false,
            ),
          ),
        );

        final textField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );
        expect(textField.enabled, false);
      });

      testWidgets('should not accept input when disabled', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              enabled: false,
            ),
          ),
        );

        // Try to enter text
        await tester.enterText(find.byType(TextFormField), 'Test');
        await tester.pump();

        // Controller should remain empty
        expect(controller.text, isEmpty);
      });
    });

    group('ReadOnly State', () {
      testWidgets('should allow editing by default', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
            ),
          ),
        );

        // Can enter text when not read-only
        await tester.enterText(find.byType(TextFormField), 'Editable');
        await tester.pump();

        expect(controller.text, 'Editable');
      });

      testWidgets('should not allow editing when readOnly is true',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              readOnly: true,
            ),
          ),
        );

        // Try to enter text - should not work
        await tester.enterText(find.byType(TextFormField), 'Should not work');
        await tester.pump();

        // Controller should remain empty for read-only
        expect(controller.text, isEmpty);
      });
    });

    group('Multiline', () {
      testWidgets('should render single line field by default', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
            ),
          ),
        );

        // Widget renders without error
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should render multiline field', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              maxLines: 5,
            ),
          ),
        );

        // Widget renders without error
        expect(find.byType(TextFormField), findsOneWidget);

        // Enter multiline text
        await tester.enterText(find.byType(TextFormField), 'Line 1\nLine 2');
        await tester.pump();

        expect(controller.text, 'Line 1\nLine 2');
      });
    });

    group('Keyboard Type', () {
      testWidgets('should render with email keyboard type', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        );

        // Widget renders without error
        expect(find.byType(TextFormField), findsOneWidget);

        // Can enter email-like text
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pump();

        expect(controller.text, 'test@example.com');
      });

      testWidgets('should render with number keyboard type', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              keyboardType: TextInputType.number,
            ),
          ),
        );

        // Widget renders without error
        expect(find.byType(TextFormField), findsOneWidget);

        // Can enter numbers
        await tester.enterText(find.byType(TextFormField), '12345');
        await tester.pump();

        expect(controller.text, '12345');
      });
    });

    group('Max Length', () {
      testWidgets('should limit input to maxLength', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              maxLength: 10,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'This is too long');
        await tester.pump();

        expect(controller.text.length, 10);
      });
    });

    group('OnTap Callback', () {
      testWidgets('should call onTap when tapped', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        expect(tapped, true);
      });
    });

    group('Value Input Style', () {
      testWidgets('should use grey background by default', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              isValueInput: false,
            ),
          ),
        );

        // Widget renders without error - visual verification
        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('should use transparent background for value input',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              isValueInput: true,
            ),
          ),
        );

        // Widget renders without error - visual verification
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Focus Node', () {
      testWidgets('should accept custom focus node', (tester) async {
        final focusNode = FocusNode();

        await tester.pumpWidget(
          buildTestWidget(
            LynewedTextField(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        );

        // Request focus
        focusNode.requestFocus();
        await tester.pump();

        expect(focusNode.hasFocus, true);

        focusNode.dispose();
      });
    });
  });
}
