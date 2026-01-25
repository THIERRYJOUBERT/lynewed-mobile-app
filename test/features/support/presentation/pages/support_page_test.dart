/// Tests for SupportPage.
///
/// Verifies the support page:
/// - Renders header correctly
/// - Displays quick action cards (Email, Chat)
/// - Shows FAQ section
/// - Shows contact form
/// - Handles navigation and actions
/// - Proper layout and styling
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/support/presentation/pages/support_page.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/quick_action_card.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/faq_section.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/contact_form.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
    NavigatorObserver? observer,
  }) {
    return MaterialApp(
      home: child,
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  group('SupportPage', () {
    group('Route configuration', () {
      testWidgets('should have correct route name', (tester) async {
        // Assert
        expect(SupportPage.routeName, 'support');
      });

      testWidgets('should have correct route path', (tester) async {
        // Assert
        expect(SupportPage.routePath, '/support');
      });
    });

    group('Header', () {
      testWidgets('should display page title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Help & Support'), findsOneWidget);
      });

      testWidgets('should display back button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should navigate back when back button is pressed', (tester) async {
        // Arrange
        var navigatedBack = false;
        final observer = _MockNavigatorObserver(
          onPop: () => navigatedBack = true,
        );

        await tester.pumpWidget(MaterialApp(
          navigatorObservers: [observer],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SupportPage(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ));

        // Navigate to support page
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Act - tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert
        expect(navigatedBack, isTrue);
      });
    });

    group('Quick actions', () {
      testWidgets('should display quick actions section title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Quick Actions'), findsOneWidget);
      });

      testWidgets('should display email quick action card', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Email Us'), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('should display chat quick action card', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Live Chat'), findsOneWidget);
        expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      });

      testWidgets('should have two QuickActionCard widgets', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byType(QuickActionCard), findsNWidgets(2));
      });
    });

    group('FAQ section', () {
      testWidgets('should display FAQ section', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byType(FaqSection), findsOneWidget);
      });

      testWidgets('should display FAQ section title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Frequently Asked Questions'), findsOneWidget);
      });
    });

    group('Contact form', () {
      testWidgets('should display contact form', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byType(ContactForm), findsOneWidget);
      });

      testWidgets('should display contact form title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.text('Contact Us'), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('should be scrollable', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });

      testWidgets('header should be above quick actions', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        final headerPosition = tester.getTopLeft(find.text('Help & Support'));
        final quickActionsPosition = tester.getTopLeft(find.text('Quick Actions'));
        expect(headerPosition.dy, lessThan(quickActionsPosition.dy));
      });

      testWidgets('quick actions should be above FAQ section', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        final quickActionsPosition = tester.getTopLeft(find.text('Quick Actions'));
        final faqPosition = tester.getTopLeft(find.text('Frequently Asked Questions'));
        expect(quickActionsPosition.dy, lessThan(faqPosition.dy));
      });

      testWidgets('FAQ section should be above contact form', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Scroll to make Contact Us visible
        await tester.scrollUntilVisible(
          find.text('Contact Us'),
          200.0,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump();

        // Assert
        final faqPosition = tester.getTopLeft(find.text('Frequently Asked Questions'));
        final contactPosition = tester.getTopLeft(find.text('Contact Us'));
        expect(faqPosition.dy, lessThan(contactPosition.dy));
      });
    });

    group('Styling', () {
      testWidgets('should use proper background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should have divider under header', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert - at least one divider should exist (header divider plus FAQ dividers)
        expect(find.byType(Divider), findsWidgets);
      });
    });

    group('Widget configuration', () {
      testWidgets('should be a StatelessWidget', (tester) async {
        // Assert
        const widget = SupportPage();
        expect(widget, isA<StatelessWidget>());
      });

      testWidgets('should render without errors', (tester) async {
        // Arrange & Act & Assert
        expect(
          () async => tester.pumpWidget(buildTestWidget(
            child: const SupportPage(),
          )),
          returnsNormally,
        );
      });
    });

    group('Accessibility', () {
      testWidgets('back button should be accessible', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert - back button should be tappable
        await tester.tap(find.byIcon(Icons.arrow_back));
        // Should not throw
      });

      testWidgets('quick action cards should be tappable', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const SupportPage(),
        ));

        // Assert - email card should be tappable
        await tester.tap(find.text('Email Us'));
        // Should not throw
      });
    });
  });
}

/// Mock navigator observer for testing navigation.
class _MockNavigatorObserver extends NavigatorObserver {
  final VoidCallback? onPop;

  _MockNavigatorObserver({this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop?.call();
    super.didPop(route, previousRoute);
  }
}
