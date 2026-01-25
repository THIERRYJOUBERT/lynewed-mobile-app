import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/design/widgets/lynewed_chip.dart';
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

  group('LynewedChip', () {
    group('Rendering', () {
      testWidgets('should render with label', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Category',
              selected: false,
              onSelected: (_) {},
            ),
          ),
        );

        expect(find.text('Category'), findsOneWidget);
        expect(find.byType(LynewedChip), findsOneWidget);
      });

      testWidgets('should render without count by default', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Tag',
              selected: false,
              onSelected: (_) {},
            ),
          ),
        );

        // Should only find the label, no count badge
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, 1);
      });

      testWidgets('should render with count when provided', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Items',
              selected: false,
              onSelected: (_) {},
              count: 5,
            ),
          ),
        );

        expect(find.text('Items'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should not render count when count is 0', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Empty',
              selected: false,
              onSelected: (_) {},
              count: 0,
            ),
          ),
        );

        expect(find.text('Empty'), findsOneWidget);
        expect(find.text('0'), findsNothing);
      });

      testWidgets('should not render count when count is null', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'No Count',
              selected: false,
              onSelected: (_) {},
              count: null,
            ),
          ),
        );

        expect(find.text('No Count'), findsOneWidget);
        // Only the label text should exist
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        expect(textWidgets.length, 1);
      });
    });

    group('Selection State', () {
      testWidgets('should render unselected state correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Unselected',
              selected: false,
              onSelected: (_) {},
            ),
          ),
        );

        // Find the container
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(LynewedChip),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        // Unselected should have light background
        expect(decoration.color, const Color(0xFFF2F2F2));
      });

      testWidgets('should render selected state correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Selected',
              selected: true,
              onSelected: (_) {},
            ),
          ),
        );

        // Find the container
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(LynewedChip),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        // Selected should have primary (dark) background
        expect(decoration.color, LynewedColors.primary);
      });

      testWidgets('should have correct text color when unselected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Unselected',
              selected: false,
              onSelected: (_) {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Unselected'));
        expect(text.style?.color, LynewedColors.textPrimary);
      });

      testWidgets('should have correct text color when selected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Selected',
              selected: true,
              onSelected: (_) {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Selected'));
        expect(text.style?.color, LynewedColors.textOnPrimary);
      });
    });

    group('Callbacks', () {
      testWidgets('should call onSelected with true when tapped while unselected',
          (tester) async {
        bool? selectedValue;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Toggle',
              selected: false,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedChip));
        await tester.pump();

        expect(selectedValue, true);
      });

      testWidgets('should call onSelected with false when tapped while selected',
          (tester) async {
        bool? selectedValue;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Toggle',
              selected: true,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        );

        await tester.tap(find.byType(LynewedChip));
        await tester.pump();

        expect(selectedValue, false);
      });

      testWidgets('should be tappable via GestureDetector', (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Tap Me',
              selected: false,
              onSelected: (_) => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(tapped, true);
      });
    });

    group('Count Badge', () {
      testWidgets('count badge should have correct color when unselected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Items',
              selected: false,
              onSelected: (_) {},
              count: 3,
            ),
          ),
        );

        // Find all containers (there should be nested ones for the badge)
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(LynewedChip),
            matching: find.byType(Container),
          ),
        );

        // The inner container should be the count badge
        bool foundBadge = false;
        for (final container in containers) {
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.color == LynewedColors.primary) {
              foundBadge = true;
              break;
            }
          }
        }
        expect(foundBadge, true);
      });

      testWidgets('count badge should have correct color when selected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Items',
              selected: true,
              onSelected: (_) {},
              count: 3,
            ),
          ),
        );

        // Find all containers
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(LynewedChip),
            matching: find.byType(Container),
          ),
        );

        // The inner container (badge) should be white when chip is selected
        bool foundWhiteBadge = false;
        for (final container in containers) {
          if (container.decoration is BoxDecoration) {
            final decoration = container.decoration as BoxDecoration;
            if (decoration.color == Colors.white) {
              foundWhiteBadge = true;
              break;
            }
          }
        }
        expect(foundWhiteBadge, true);
      });

      testWidgets('count text should have correct color when unselected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Items',
              selected: false,
              onSelected: (_) {},
              count: 5,
            ),
          ),
        );

        final countText = tester.widget<Text>(find.text('5'));
        expect(countText.style?.color, Colors.white);
      });

      testWidgets('count text should have correct color when selected',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Items',
              selected: true,
              onSelected: (_) {},
              count: 5,
            ),
          ),
        );

        final countText = tester.widget<Text>(find.text('5'));
        expect(countText.style?.color, LynewedColors.primary);
      });
    });

    group('Border Radius', () {
      testWidgets('should have correct border radius', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            LynewedChip(
              label: 'Rounded',
              selected: false,
              onSelected: (_) {},
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(LynewedChip),
            matching: find.byType(Container),
          ).first,
        );

        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(4));
      });
    });
  });
}
