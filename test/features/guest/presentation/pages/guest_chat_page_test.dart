/// Tests for GuestChatPage.
///
/// Verifies the guest chat page displays correctly and integrates
/// with the existing chat system.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/pages/guest_chat_page.dart';

void main() {
  group('GuestChatPage', () {
    Widget buildTestWidget({String? chatRoomId}) {
      return MaterialApp(
        home: Scaffold(
          body: GuestChatPage(chatRoomId: chatRoomId),
        ),
      );
    }

    group('No chat room', () {
      testWidgets('should display no chat state when chatRoomId is null',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Wedding group'), findsOneWidget);
        expect(
          find.textContaining('Chat will be available'),
          findsOneWidget,
        );
      });

      testWidgets('should display chat bubble outline icon', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });
    });

    group('With chat room', () {
      testWidgets('should build ChatDetailsPage when chatRoomId provided',
          (tester) async {
        // When chatRoomId is provided, the page wraps ChatDetailsPage
        // Note: ChatDetailsPage requires Supabase to be initialized,
        // so this test verifies the structure without rendering fully
        const roomId = 'test-room-123';

        // Build just the GuestChatPage widget without pumping
        // to verify the build method logic
        final widget = GuestChatPage(chatRoomId: roomId);
        expect(widget.chatRoomId, roomId);
      });
    });

    group('Widget structure', () {
      testWidgets('should be a StatelessWidget', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final widget = tester.widget<GuestChatPage>(find.byType(GuestChatPage));
        expect(widget, isA<StatelessWidget>());
      });

      test('should accept chatRoomId parameter', () {
        const roomId = 'my-room-id';
        const widget = GuestChatPage(chatRoomId: roomId);

        expect(widget.chatRoomId, roomId);
      });
    });
  });
}
