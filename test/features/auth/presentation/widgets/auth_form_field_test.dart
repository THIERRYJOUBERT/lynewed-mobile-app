/// Tests for AuthFormField widget.
///
/// Verifies the custom form field component displays correctly with:
/// - Label and hint text
/// - Password visibility toggle
/// - Validation error messages
/// - Suffix icons
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/auth_form_field.dart';

void main() {
  group('AuthFormField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildTestWidget({
      required Widget child,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display label when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Email',
          ),
        ));

        // Assert
        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('should display hint text in text field', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            hint: 'Enter your email',
          ),
        ));

        // Assert
        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('should render without label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            hint: 'Email',
          ),
        ));

        // Assert - Should not crash
        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Password field behavior', () {
      testWidgets('should obscure text when obscureText is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ));

        // Assert - Find EditableText which has the actual obscureText property
        final editableText = tester.widget<EditableText>(find.byType(EditableText));
        expect(editableText.obscureText, isTrue);
      });

      testWidgets('should toggle password visibility when suffix icon tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ));

        // Initially obscured
        var editableText = tester.widget<EditableText>(find.byType(EditableText));
        expect(editableText.obscureText, isTrue);

        // Act - tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Assert - should now be visible
        editableText = tester.widget<EditableText>(find.byType(EditableText));
        expect(editableText.obscureText, isFalse);

        // Tap again to hide
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Should be obscured again
        editableText = tester.widget<EditableText>(find.byType(EditableText));
        expect(editableText.obscureText, isTrue);
      });

      testWidgets('should show visibility toggle icon for password fields', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Password',
            obscureText: true,
          ),
        ));

        // Assert - should show visibility_off icon when obscured
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('Suffix icon', () {
      testWidgets('should display suffix icon when provided (non-password)', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Email',
            suffixIcon: const Icon(Icons.email, key: Key('suffix-icon')),
          ),
        ));

        // Assert
        expect(find.byKey(const Key('suffix-icon')), findsOneWidget);
      });

      testWidgets('should show visibility toggle instead of suffix icon for password', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Password',
            obscureText: true,
            suffixIcon: const Icon(Icons.email, key: Key('suffix-icon')),
          ),
        ));

        // Assert - visibility toggle takes precedence
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byKey(const Key('suffix-icon')), findsNothing);
      });
    });

    group('Validation', () {
      testWidgets('should display validation error message', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AuthFormField(
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
          ),
        ));

        // Act - validate with empty field
        formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should not display error when validation passes', (tester) async {
        // Arrange
        controller.text = 'test@example.com';
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AuthFormField(
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
          ),
        ));

        // Act - validate with filled field
        final isValid = formKey.currentState!.validate();
        await tester.pump();

        // Assert
        expect(isValid, isTrue);
        expect(find.text('Email is required'), findsNothing);
      });
    });

    group('Text input', () {
      testWidgets('should update controller when text is entered', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Email',
          ),
        ));

        // Act
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.pump();

        // Assert
        expect(controller.text, 'test@example.com');
      });

      testWidgets('should use correct keyboard type for email', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ));

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.emailAddress);
      });
    });

    group('Focus and submission', () {
      testWidgets('should call onFieldSubmitted when field is submitted', (tester) async {
        // Arrange
        String? submittedValue;
        await tester.pumpWidget(buildTestWidget(
          child: AuthFormField(
            controller: controller,
            label: 'Email',
            onFieldSubmitted: (value) => submittedValue = value,
          ),
        ));

        // Act
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(submittedValue, 'test@example.com');
      });
    });
  });
}
