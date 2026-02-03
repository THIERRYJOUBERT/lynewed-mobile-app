/// Tests for GuestSignupForm widget.
///
/// Verifies the guest signup form including:
/// - Field validation
/// - Terms checkbox
/// - Form submission
/// - Error display
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/guest_signup_form.dart';

void main() {
  group('GuestSignupForm', () {
    Widget buildTestWidget({
      String? initialEmail,
      bool isLoading = false,
      String? errorMessage,
      required GuestSignupCallback onSubmit,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GuestSignupForm(
                initialEmail: initialEmail,
                isLoading: isLoading,
                errorMessage: errorMessage,
                onSubmit: onSubmit,
              ),
            ),
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display all form fields', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.text('Prénom'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Mot de passe'), findsOneWidget);
      });

      testWidgets('should display submit button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.text('Créer mon compte invité'), findsOneWidget);
      });

      testWidgets('should display terms checkbox', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.byType(Checkbox), findsOneWidget);
        // Terms text uses Text.rich so we need to find the rich text widget
        expect(find.textContaining("conditions d'utilisation"), findsOneWidget);
      });
    });

    group('Initial email', () {
      testWidgets('should pre-fill email when initialEmail provided',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          initialEmail: 'pierre@example.com',
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.text('pierre@example.com'), findsOneWidget);
      });
    });

    group('Form validation', () {
      testWidgets('submit button should be disabled when form is incomplete',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Assert - button should be disabled initially
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Créer mon compte invité'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('submit button should be disabled when terms not accepted',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Act - fill all fields but don't accept terms
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'),
            'pierre@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.pump();

        // Assert - button should still be disabled
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Créer mon compte invité'),
        );
        expect(button.onPressed, isNull);

        // Should show terms warning
        expect(find.text('Veuillez accepter les conditions'), findsOneWidget);
      });

      testWidgets('submit button should be enabled when form is complete',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Act - fill all fields and accept terms
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'),
            'pierre@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert - button should be enabled
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Créer mon compte invité'),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('Form submission', () {
      testWidgets('should call onSubmit with correct values', (tester) async {
        // Arrange
        String? submittedFirstName;
        String? submittedEmail;
        String? submittedPassword;

        await tester.pumpWidget(buildTestWidget(
          onSubmit: (firstName, email, password) {
            submittedFirstName = firstName;
            submittedEmail = email;
            submittedPassword = password;
          },
        ));

        // Act - fill and submit form
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'PIERRE@Example.COM');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        await tester.tap(find.text('Créer mon compte invité'));
        await tester.pump();

        // Assert
        expect(submittedFirstName, 'Pierre');
        expect(submittedEmail, 'pierre@example.com'); // Should be lowercase
        expect(submittedPassword, 'SecurePass123!');
      });
    });

    group('Loading state', () {
      testWidgets('should disable form fields when loading', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          isLoading: true,
          onSubmit: (_, __, ___) {},
        ));

        // Assert - form fields should be disabled
        final textFields = tester.widgetList<TextFormField>(
          find.byType(TextFormField),
        );
        for (final field in textFields) {
          expect(field.enabled, isFalse);
        }
      });

      testWidgets('should show loading indicator in button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          isLoading: true,
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Error display', () {
      testWidgets('should display error message when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          errorMessage: 'Cet email est déjà utilisé',
          onSubmit: (_, __, ___) {},
        ));

        // Assert
        expect(find.text('Cet email est déjà utilisé'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Password visibility', () {
      testWidgets('should toggle password visibility', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          onSubmit: (_, __, ___) {},
        ));

        // Act - enter password
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.pump();

        // Assert - password should be hidden by default
        final passwordField =
            tester.widget<TextField>(find.byType(TextField).last);
        expect(passwordField.obscureText, isTrue);

        // Act - tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // Assert - password should be visible
        final visiblePasswordField =
            tester.widget<TextField>(find.byType(TextField).last);
        expect(visiblePasswordField.obscureText, isFalse);
      });
    });
  });
}
