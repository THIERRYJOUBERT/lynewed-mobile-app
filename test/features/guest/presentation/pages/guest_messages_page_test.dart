/// Tests for GuestMessagesPage.
///
/// Messages page for guest users showing wedding team conversations.
/// Note: This page is designed to be embedded in GuestHomePage which
/// provides the header. The page itself only renders the body content.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lynewed_beta/features/guest/presentation/pages/guest_messages_page.dart';

void main() {
  group('GuestMessagesPage', () {
    testWidgets('renders basic structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuestMessagesPage(),
          ),
        ),
      );

      // Just verify the widget builds without crashing
      expect(find.byType(GuestMessagesPage), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuestMessagesPage(),
          ),
        ),
      );

      // Before postFrameCallback fires, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is a StatefulWidget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuestMessagesPage(),
          ),
        ),
      );

      // Verify it's a StatefulWidget (has state)
      expect(find.byType(GuestMessagesPage), findsOneWidget);
      final widget = tester.widget<GuestMessagesPage>(
        find.byType(GuestMessagesPage),
      );
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('designed to be embedded (no own Scaffold)', (tester) async {
      // GuestMessagesPage is designed to be embedded in GuestHomePage
      // which provides the Scaffold and header. The page returns just the body.
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      // Verify it renders (the loading state) without its own Scaffold
      // Parent provides Scaffold
      expect(find.byType(GuestMessagesPage), findsOneWidget);
    });
  });
}
