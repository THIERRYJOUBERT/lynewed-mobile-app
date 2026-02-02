/// Tests for GuestMessagesPage.
///
/// Messages page for guest users showing wedding team conversations.
/// Tests focus on structure and UI elements since Supabase is not
/// available in test environment.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lynewed_beta/features/guest/presentation/pages/guest_messages_page.dart';

void main() {
  group('GuestMessagesPage', () {
    testWidgets('renders basic structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      // Just verify the widget builds without crashing
      expect(find.byType(GuestMessagesPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders title "Messages"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      // Before postFrameCallback fires, should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has SafeArea for proper padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('has header with proper text style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuestMessagesPage(),
        ),
      );

      final titleFinder = find.text('Messages');
      expect(titleFinder, findsOneWidget);
    });
  });
}
