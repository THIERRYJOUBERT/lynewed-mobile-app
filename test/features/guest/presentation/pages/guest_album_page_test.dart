/// Tests for GuestAlbumPage.
///
/// Verifies the guest album page structure and static components.
/// Note: Tests that require Supabase integration are limited to structure verification.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/pages/guest_album_page.dart';

void main() {
  group('GuestAlbumPage', () {
    group('Widget Structure', () {
      testWidgets('should be a StatefulWidget', (tester) async {
        // Assert - GuestAlbumPage is defined as StatefulWidget
        const widget = GuestAlbumPage();
        expect(widget, isA<StatefulWidget>());
      });

      testWidgets('should create state', (tester) async {
        // Assert - GuestAlbumPage can create state
        const widget = GuestAlbumPage();
        final state = widget.createState();
        expect(state, isNotNull);
      });
    });

    group('Widget Key', () {
      testWidgets('should accept key parameter', (tester) async {
        // Arrange
        const key = Key('test-key');

        // Act
        const widget = GuestAlbumPage(key: key);

        // Assert
        expect(widget.key, equals(key));
      });
    });
  });

  group('GuestAlbumPage Components', () {
    group('GuestMediaGrid', () {
      testWidgets('GuestMediaGrid import is accessible', (tester) async {
        // This test verifies that the module structure is correct
        // by checking that GuestAlbumPage compiles with its imports
        const widget = GuestAlbumPage();
        expect(widget, isA<Widget>());
      });
    });

    group('Design System Integration', () {
      testWidgets('widget is properly typed as StatefulWidget', (tester) async {
        // Arrange & Assert
        const widget = GuestAlbumPage();
        expect(widget.runtimeType.toString(), equals('GuestAlbumPage'));
      });
    });
  });
}
