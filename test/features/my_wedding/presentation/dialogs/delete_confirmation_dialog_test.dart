/// Tests for DeleteConfirmationDialog
///
/// Tests the delete confirmation dialog for single and batch deletion.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/dialogs/delete_confirmation_dialog.dart';

void main() {
  group('DeleteConfirmationDialog', () {
    testWidgets('should show singular text for single item', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 1,
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Remove photo?'), findsOneWidget);
      expect(
        find.text('This photo will be removed from your gallery.'),
        findsOneWidget,
      );
    });

    testWidgets('should show plural text for multiple items', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 5,
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Remove 5 photos?'), findsOneWidget);
      expect(
        find.text('These 5 photos will be removed from your gallery.'),
        findsOneWidget,
      );
    });

    testWidgets('should show info about guest still seeing photos',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 1,
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('The guest will still see it in their album.'),
        findsOneWidget,
      );
    });

    testWidgets('should have Cancel and Delete buttons', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 1,
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 1,
                    onConfirm: () {},
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - dialog should be closed
      expect(find.text('Remove photo?'), findsNothing);
    });

    testWidgets('should call onConfirm and close when Delete is tapped',
        (tester) async {
      // Arrange
      var confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => DeleteConfirmationDialog(
                    count: 1,
                    onConfirm: () => confirmCalled = true,
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(confirmCalled, true);
      expect(find.text('Remove photo?'), findsNothing);
    });
  });

  group('showDeleteConfirmationDialog', () {
    testWidgets('should return true when user confirms', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDeleteConfirmationDialog(
                    context: context,
                    count: 1,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, true);
    });

    testWidgets('should return false when user cancels', (tester) async {
      // Arrange
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDeleteConfirmationDialog(
                    context: context,
                    count: 1,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(result, false);
    });
  });
}
