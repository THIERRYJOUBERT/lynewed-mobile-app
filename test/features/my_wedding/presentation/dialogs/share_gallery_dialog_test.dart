/// Tests for ShareGalleryDialog
///
/// Tests the share confirmation dialog UI and behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/presentation/dialogs/share_gallery_dialog.dart';

void main() {
  group('ShareGalleryDialog', () {
    testWidgets('should display title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Share with Guests'), findsOneWidget);
    });

    testWidgets('should display correct count for single photo', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 1,
              isSharing: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('1 photo'), findsOneWidget);
    });

    testWidgets('should display correct count for multiple photos', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 10,
              isSharing: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('10 photos'), findsOneWidget);
    });

    testWidgets('should display Cancel and Share buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('should call onCancel when Cancel is tapped', (tester) async {
      // Arrange
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(cancelled, true);
    });

    testWidgets('should call onShare when Share is tapped', (tester) async {
      // Arrange
      bool shared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
              onShare: () => shared = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      // Assert
      expect(shared, true);
    });

    testWidgets('should show loading indicator when isSharing is true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('should disable buttons when isSharing is true', (tester) async {
      // Arrange
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: true,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pump(); // Just pump once, don't pumpAndSettle with spinner

      // Assert - callback should not be called when disabled
      expect(cancelled, false);
    });

    testWidgets('should display description text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('view and download'), findsOneWidget);
    });
  });

  group('ShareGalleryDialog for unshare', () {
    testWidgets('should display unshare title when isUnshare is true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
              isUnshare: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Unshare Photos'), findsOneWidget);
    });

    testWidgets('should display Unshare button when isUnshare is true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShareGalleryDialog(
              photoCount: 5,
              isSharing: false,
              isUnshare: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Unshare'), findsOneWidget);
    });
  });
}
