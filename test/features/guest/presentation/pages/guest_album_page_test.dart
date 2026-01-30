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
        expect(find.text('Mes photos et vidéos'), findsOneWidget);
      });

      testWidgets('should display empty state message', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Ajoutez vos photos du mariage !'), findsOneWidget);
      });

      testWidgets('should display add button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Ajouter photo/vidéo'), findsOneWidget);
        expect(find.byIcon(Icons.add_photo_alternate), findsOneWidget);
      });

      testWidgets('should display photo library icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.photo_library), findsOneWidget);
      });
    });

    group('Interaction', () {
      testWidgets('add button should show snackbar (placeholder)', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.text('Ajouter photo/vidéo'));
        await tester.pump();

        // Assert
        expect(find.text('Cette fonctionnalité arrive bientôt !'), findsOneWidget);
      });
    });
  });
}
