/// Tests for GuestAlbumPage.
///
/// Verifies the guest album page displays correctly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/pages/guest_album_page.dart';

void main() {
  group('GuestAlbumPage', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: GuestAlbumPage(),
        ),
      );
    }

    group('Basic rendering', () {
      testWidgets('should display header text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Your Wedding Memories'), findsOneWidget);
      });

      testWidgets('should display empty state message', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(
          find.textContaining('Photos and videos you capture'),
          findsOneWidget,
        );
      });

      testWidgets('should display FAB', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should display photo library outlined icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('FAB should show snackbar (placeholder)', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert
        expect(
          find.text('Photo upload coming in next update!'),
          findsOneWidget,
        );
      });
    });
  });
}
