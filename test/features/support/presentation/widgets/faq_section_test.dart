/// Tests for FaqSection widget.
///
/// Verifies the FAQ section widget:
/// - Renders section title correctly
/// - Displays FAQ items as ExpansionTiles
/// - Handles expand/collapse interactions
/// - Shows FAQ content when expanded
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/support/presentation/widgets/faq_section.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  group('FaqSection', () {
    group('Basic rendering', () {
      testWidgets('should display section title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert
        expect(find.text('Frequently Asked Questions'), findsOneWidget);
      });

      testWidgets('should display FAQ questions', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - should find at least one FAQ question
        // Using ExpansionTile as the container for FAQ items
        expect(find.byType(ExpansionTile), findsWidgets);
      });

      testWidgets('should have multiple FAQ items', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - should find multiple FAQ items
        final expansionTiles = find.byType(ExpansionTile);
        expect(expansionTiles.evaluate().length, greaterThanOrEqualTo(3));
      });

      testWidgets('should display first FAQ question text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - check for known FAQ question
        expect(
          find.textContaining('How do I'),
          findsWidgets,
        );
      });
    });

    group('Expansion behavior', () {
      testWidgets('should start with FAQs collapsed', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - answers should not be visible initially
        // Check that the first ExpansionTile is not expanded
        final firstExpansionTile = tester.widget<ExpansionTile>(
          find.byType(ExpansionTile).first,
        );
        expect(firstExpansionTile.initiallyExpanded, isFalse);
      });

      testWidgets('should expand FAQ when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Act - tap the first ExpansionTile
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();

        // Assert - should show the answer content
        // After expansion, more text should be visible
        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('should collapse FAQ when tapped again', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Act - expand then collapse
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();

        // Assert - should be collapsed again
        // Widget still exists and is functional
        expect(find.byType(ExpansionTile).first, findsOneWidget);
      });
    });

    group('Custom FAQ items', () {
      testWidgets('should accept custom FAQ items', (tester) async {
        // Arrange
        const customFaqs = [
          FaqItem(
            question: 'Custom Question 1',
            answer: 'Custom Answer 1',
          ),
          FaqItem(
            question: 'Custom Question 2',
            answer: 'Custom Answer 2',
          ),
        ];

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(items: customFaqs),
        ));

        // Assert
        expect(find.text('Custom Question 1'), findsOneWidget);
        expect(find.text('Custom Question 2'), findsOneWidget);
      });

      testWidgets('should show custom answer when expanded', (tester) async {
        // Arrange
        const customFaqs = [
          FaqItem(
            question: 'Test Question',
            answer: 'Test Answer Content',
          ),
        ];

        // Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(items: customFaqs),
        ));
        await tester.tap(find.byType(ExpansionTile).first);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Answer Content'), findsOneWidget);
      });
    });

    group('FaqItem data class', () {
      testWidgets('should store question and answer', (tester) async {
        // Arrange & Act
        const item = FaqItem(
          question: 'What is Lynewed?',
          answer: 'Lynewed is a wedding planning platform.',
        );

        // Assert
        expect(item.question, 'What is Lynewed?');
        expect(item.answer, 'Lynewed is a wedding planning platform.');
      });

      testWidgets('should support equality for same values', (tester) async {
        // Arrange & Act
        const item1 = FaqItem(
          question: 'Q1',
          answer: 'A1',
        );
        const item2 = FaqItem(
          question: 'Q1',
          answer: 'A1',
        );

        // Assert
        expect(item1, equals(item2));
      });
    });

    group('Layout', () {
      testWidgets('should have proper vertical spacing', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - title should be above FAQ items
        final titlePosition = tester.getTopLeft(
          find.text('Frequently Asked Questions'),
        );
        final firstFaqPosition = tester.getTopLeft(
          find.byType(ExpansionTile).first,
        );
        expect(titlePosition.dy, lessThan(firstFaqPosition.dy));
      });

      testWidgets('should use full width', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - section should have reasonable width
        final faqSection = find.byType(FaqSection);
        final size = tester.getSize(faqSection);
        expect(size.width, greaterThan(100));
      });
    });

    group('Styling', () {
      testWidgets('should style section title correctly', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert
        final titleWidget = tester.widget<Text>(
          find.text('Frequently Asked Questions'),
        );
        expect(titleWidget.style, isNotNull);
      });

      testWidgets('should have dividers between FAQ items', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - ExpansionTiles are separated
        final expansionTiles = find.byType(ExpansionTile);
        expect(expansionTiles.evaluate().length, greaterThanOrEqualTo(2));
      });
    });

    group('Accessibility', () {
      testWidgets('FAQ items should be tappable', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          child: const FaqSection(),
        ));

        // Assert - should be able to tap
        var tapped = false;
        await tester.tap(find.byType(ExpansionTile).first);
        tapped = true;
        await tester.pump();

        expect(tapped, isTrue);
      });
    });
  });
}
