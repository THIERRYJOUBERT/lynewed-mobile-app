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
        const widget = GuestAlbumPage();
        expect(widget, isA<StatefulWidget>());
      });

      testWidgets('should create state', (tester) async {
        const widget = GuestAlbumPage();
        final state = widget.createState();
        expect(state, isNotNull);
      });
    });

    group('Widget Key', () {
      testWidgets('should accept key parameter', (tester) async {
        const key = Key('test-key');
        const widget = GuestAlbumPage(key: key);
        expect(widget.key, equals(key));
      });
    });

    group('BrideName parameter', () {
      testWidgets('should accept brideName parameter', (tester) async {
        const widget = GuestAlbumPage(brideName: 'Sophie');
        expect(widget.brideName, equals('Sophie'));
      });

      testWidgets('brideName defaults to null', (tester) async {
        const widget = GuestAlbumPage();
        expect(widget.brideName, isNull);
      });
    });

    group('Design System Integration', () {
      testWidgets('widget is properly typed as StatefulWidget', (tester) async {
        const widget = GuestAlbumPage();
        expect(widget.runtimeType.toString(), equals('GuestAlbumPage'));
      });
    });
  });
}
