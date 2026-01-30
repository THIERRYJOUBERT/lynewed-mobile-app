/// Tests for GuestJoinButton widget.
///
/// Verifies the button component for guest users to access
/// the join wedding flow displays correctly and triggers callbacks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/guest_join_button.dart';

void main() {
  group('GuestJoinButton', () {
    Widget buildTestWidget({
      required VoidCallback onPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GuestJoinButton(
            onPressed: onPressed,
          ),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display OR divider text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert
        expect(find.text('OR'), findsOneWidget);
      });

      testWidgets('should display guest join label text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert
        expect(find.text("Rejoindre en tant qu'invité"), findsOneWidget);
      });

      testWidgets('should display person add icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert
        expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
      });

      testWidgets('should display horizontal dividers', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert - two Divider widgets
        expect(find.byType(Divider), findsNWidgets(2));
      });
    });

    group('Layout', () {
      testWidgets('should render dividers and OR text in a row', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert - Row widget should exist with Expanded children
        expect(find.byType(Row), findsWidgets);
        expect(find.byType(Expanded), findsNWidgets(2));
      });

      testWidgets('should be contained in a Column', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert
        expect(find.byType(Column), findsWidgets);
      });
    });

    group('Interaction', () {
      testWidgets('should trigger onPressed callback when tapped', (tester) async {
        // Arrange
        var wasPressed = false;
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {
            wasPressed = true;
          },
        ));

        // Act - tap on the label text
        await tester.tap(find.text("Rejoindre en tant qu'invité"));
        await tester.pump();

        // Assert
        expect(wasPressed, isTrue);
      });

      testWidgets('should be tappable via the label text', (tester) async {
        // Arrange
        var wasPressed = false;
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {
            wasPressed = true;
          },
        ));

        // Act
        await tester.tap(find.text("Rejoindre en tant qu'invité"));
        await tester.pump();

        // Assert
        expect(wasPressed, isTrue);
      });

      testWidgets('should be tappable via the icon', (tester) async {
        // Arrange
        var wasPressed = false;
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {
            wasPressed = true;
          },
        ));

        // Act
        await tester.tap(find.byIcon(Icons.person_add_outlined));
        await tester.pump();

        // Assert
        expect(wasPressed, isTrue);
      });
    });

    group('Widget structure', () {
      testWidgets('should have tappable button with icon and label', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert - TextButton.icon creates a widget tree, verify components exist
        expect(find.byIcon(Icons.person_add_outlined), findsOneWidget);
        expect(find.text("Rejoindre en tant qu'invité"), findsOneWidget);
      });

      testWidgets('should be compact with mainAxisSize.min', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(
          onPressed: () {},
        ));

        // Assert - the widget should only take minimum vertical space
        final guestButton = find.byType(GuestJoinButton);
        expect(guestButton, findsOneWidget);

        // Column should have mainAxisSize.min
        final columns = tester.widgetList<Column>(find.byType(Column));
        final guestButtonColumn = columns.firstWhere(
          (col) => col.mainAxisSize == MainAxisSize.min,
          orElse: () => throw StateError('No Column with mainAxisSize.min found'),
        );
        expect(guestButtonColumn.mainAxisSize, MainAxisSize.min);
      });
    });
  });
}
