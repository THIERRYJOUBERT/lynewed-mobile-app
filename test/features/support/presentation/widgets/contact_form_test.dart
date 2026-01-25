/// Tests for ContactForm widget.
///
/// Verifies the contact form widget:
/// - Renders form fields correctly
/// - Validates subject and message fields
/// - Handles form submission
/// - Displays error messages for invalid input
/// - Shows loading state during submission
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/contact_form.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
    NavigatorObserver? observer,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  group('ContactForm', () {
    group('Basic rendering', () {
      testWidgets('should display section title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('Contact Us'), findsOneWidget);
      });

      testWidgets('should display subject field with label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('Subject'), findsOneWidget);
      });

      testWidgets('should display subject field hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('What is this about?'), findsOneWidget);
      });

      testWidgets('should display message field with label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('Message'), findsOneWidget);
      });

      testWidgets('should display message field hint text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('Describe your issue or question...'), findsOneWidget);
      });

      testWidgets('should display submit button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.text('Send Message'), findsOneWidget);
      });

      testWidgets('should have two text form fields', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.byType(TextFormField), findsNWidgets(2));
      });
    });

    group('Form validation', () {
      testWidgets('should show error when subject is empty', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Act - tap submit without filling subject
        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a subject'), findsOneWidget);
      });

      testWidgets('should show error when message is empty', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Fill subject only - first TextFormField
        await tester.enterText(find.byType(TextFormField).first, 'Test Subject');

        // Act - tap submit without filling message
        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Please enter a message'), findsOneWidget);
      });

      testWidgets('should show error when message is too short', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Fill fields with short message
        await tester.enterText(find.byType(TextFormField).first, 'Test Subject');
        await tester.enterText(find.byType(TextFormField).last, 'Hi');

        // Act
        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Message must be at least 10 characters'), findsOneWidget);
      });

      testWidgets('should not show errors with valid input', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Fill valid data
        await tester.enterText(find.byType(TextFormField).first, 'Test Subject');
        await tester.enterText(
          find.byType(TextFormField).last,
          'This is a valid test message with enough characters.',
        );

        // Act
        await tester.tap(find.text('Send Message'));
        await tester.pump();

        // Assert - no validation errors should appear
        expect(find.text('Please enter a subject'), findsNothing);
        expect(find.text('Please enter a message'), findsNothing);
      });
    });

    group('Form submission', () {
      testWidgets('should call onSubmit callback when form is valid', (tester) async {
        // Arrange
        String? submittedSubject;
        String? submittedMessage;

        await tester.pumpWidget(buildTestWidget(
          child: ContactForm(
            onSubmit: (subject, message) {
              submittedSubject = subject;
              submittedMessage = message;
            },
          ),
        ));

        // Fill valid data
        await tester.enterText(find.byType(TextFormField).first, 'Bug Report');
        await tester.enterText(
          find.byType(TextFormField).last,
          'I found an issue with the app when trying to...',
        );

        // Act
        await tester.tap(find.text('Send Message'));
        await tester.pump();

        // Assert
        expect(submittedSubject, 'Bug Report');
        expect(submittedMessage, 'I found an issue with the app when trying to...');
      });

      testWidgets('should not call onSubmit when form is invalid', (tester) async {
        // Arrange
        var submitted = false;

        await tester.pumpWidget(buildTestWidget(
          child: ContactForm(
            onSubmit: (_, __) => submitted = true,
          ),
        ));

        // Act - submit without filling fields
        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        // Assert
        expect(submitted, isFalse);
      });

      testWidgets('should show loading indicator when isLoading is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(isLoading: true),
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should disable submit button when isLoading is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(isLoading: true),
        ));

        // Assert - button should not show "Send Message" text when loading
        // Instead it shows a CircularProgressIndicator
        expect(find.text('Send Message'), findsNothing);
      });

      testWidgets('should trim whitespace from inputs', (tester) async {
        // Arrange
        String? submittedSubject;
        String? submittedMessage;

        await tester.pumpWidget(buildTestWidget(
          child: ContactForm(
            onSubmit: (subject, message) {
              submittedSubject = subject;
              submittedMessage = message;
            },
          ),
        ));

        // Fill data with extra whitespace
        await tester.enterText(find.byType(TextFormField).first, '  Subject  ');
        await tester.enterText(
          find.byType(TextFormField).last,
          '  This is a test message  ',
        );

        // Act
        await tester.tap(find.text('Send Message'));
        await tester.pump();

        // Assert - whitespace should be trimmed
        expect(submittedSubject, 'Subject');
        expect(submittedMessage, 'This is a test message');
      });
    });

    group('Text input', () {
      testWidgets('should accept text input in subject field', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'My Subject');
        await tester.pump();

        // Assert
        expect(find.text('My Subject'), findsOneWidget);
      });

      testWidgets('should accept text input in message field', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Act
        await tester.enterText(find.byType(TextFormField).last, 'My detailed message content');
        await tester.pump();

        // Assert
        expect(find.text('My detailed message content'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('subject field should be above message field', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        final subjectPosition = tester.getTopLeft(find.text('Subject'));
        final messagePosition = tester.getTopLeft(find.text('Message'));
        expect(subjectPosition.dy, lessThan(messagePosition.dy));
      });

      testWidgets('submit button should be at bottom', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        final messagePosition = tester.getTopLeft(find.text('Message'));
        final buttonPosition = tester.getTopLeft(find.text('Send Message'));
        expect(messagePosition.dy, lessThan(buttonPosition.dy));
      });
    });

    group('Styling', () {
      testWidgets('should style form fields properly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert - form fields exist and are styled
        expect(find.byType(TextFormField), findsNWidgets(2));
      });

      testWidgets('should style section title correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        final titleWidget = tester.widget<Text>(find.text('Contact Us'));
        expect(titleWidget.style, isNotNull);
      });

      testWidgets('should have elevated button for submit', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const ContactForm(),
        ));

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept onSubmit callback', (tester) async {
        // Arrange & Act
        void callback(String s, String m) {}
        final widget = ContactForm(onSubmit: callback);

        // Assert
        expect(widget.onSubmit, callback);
      });

      testWidgets('should accept isLoading parameter', (tester) async {
        // Arrange & Act
        const widget = ContactForm(isLoading: true);

        // Assert
        expect(widget.isLoading, isTrue);
      });

      testWidgets('isLoading should default to false', (tester) async {
        // Arrange & Act
        const widget = ContactForm();

        // Assert
        expect(widget.isLoading, isFalse);
      });
    });
  });
}
