/// Tests for MarketplaceChatPage.
///
/// Verifies loading state, empty state, error state with retry,
/// message display, send message, and mark as read on open.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/marketplace_chat_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/chat_bubble_widget.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/chat_input_bar.dart';

// =============================================================================
// MOCK REPOSITORY
// =============================================================================

class MockMarketplaceChatRepository implements MarketplaceChatRepository {
  List<MarketplaceMessage> messagesToReturn = [];
  List<MarketplaceConversation> conversationsToReturn = [];
  Exception? getMessagesException;
  MarketplaceMessage? sentMessage;
  bool markAsReadCalled = false;
  String? lastMarkAsReadListingId;
  String? lastMarkAsReadOtherUserId;
  bool unsubscribeAllCalled = false;
  int sendMessageCallCount = 0;
  final StreamController<MarketplaceMessage> _realtimeController =
      StreamController<MarketplaceMessage>.broadcast();

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) async {
    if (getMessagesException != null) throw getMessagesException!;
    return messagesToReturn;
  }

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async {
    sendMessageCallCount++;
    sentMessage = MarketplaceMessage(
      id: 'sent-$sendMessageCallCount',
      listingId: listingId,
      senderId: 'current-user',
      receiverId: receiverId,
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );
    return sentMessage!;
  }

  @override
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) {
    return _realtimeController.stream;
  }

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {
    markAsReadCalled = true;
    lastMarkAsReadListingId = listingId;
    lastMarkAsReadOtherUserId = otherUserId;
  }

  @override
  Future<List<MarketplaceConversation>> getConversations() async {
    return conversationsToReturn;
  }

  @override
  void unsubscribeAll() {
    unsubscribeAllCalled = true;
  }

  /// Simulate a real-time message arriving.
  void emitRealtimeMessage(MarketplaceMessage message) {
    _realtimeController.add(message);
  }

  void dispose() {
    _realtimeController.close();
  }
}

// =============================================================================
// TEST HELPERS
// =============================================================================

final _now = DateTime(2026, 2, 4, 10, 0);

MarketplaceMessage _createMessage({
  String id = 'msg-1',
  String listingId = 'listing-1',
  String senderId = 'current-user',
  String receiverId = 'other-user',
  String content = 'Hello!',
  bool isRead = false,
  DateTime? createdAt,
}) {
  return MarketplaceMessage(
    id: id,
    listingId: listingId,
    senderId: senderId,
    receiverId: receiverId,
    content: content,
    isRead: isRead,
    createdAt: createdAt ?? _now,
  );
}

void main() {
  late MockMarketplaceChatRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketplaceChatRepository();
  });

  tearDown(() {
    mockRepository.dispose();
  });

  Widget buildPage({
    String listingId = 'listing-1',
    String otherUserId = 'other-user',
    String? listingTitle,
    String currentUserId = 'current-user',
  }) {
    return MaterialApp(
      home: MarketplaceChatPage(
        listingId: listingId,
        otherUserId: otherUserId,
        listingTitle: listingTitle,
        repository: mockRepository,
        currentUserId: currentUserId,
      ),
    );
  }

  group('MarketplaceChatPage', () {
    // ==========================================================
    // LOADING STATE
    // ==========================================================

    group('loading state', () {
      testWidgets('should show loading indicator while messages load',
          (tester) async {
        final completer = Completer<List<MarketplaceMessage>>();
        mockRepository.getMessagesException = null;
        // Override getMessages to hang.
        mockRepository.messagesToReturn = [];

        // Use a delayed repository response.
        final delayedRepo = _DelayedMockRepository(completer);

        await tester.pumpWidget(
          MaterialApp(
            home: MarketplaceChatPage(
              listingId: 'listing-1',
              otherUserId: 'other-user',
              repository: delayedRepo,
              currentUserId: 'current-user',
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete to avoid pending timer.
        completer.complete([]);
        await tester.pumpAndSettle();
      });
    });

    // ==========================================================
    // EMPTY STATE
    // ==========================================================

    group('empty state', () {
      testWidgets('should show empty state when no messages', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('No messages yet'), findsOneWidget);
        expect(
          find.text('Send a message to start the conversation'),
          findsOneWidget,
        );
      });
    });

    // ==========================================================
    // ERROR STATE
    // ==========================================================

    group('error state', () {
      testWidgets('should show error state when loading fails',
          (tester) async {
        mockRepository.getMessagesException =
            Exception('Network error');

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load messages'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry loading when Retry button is tapped',
          (tester) async {
        mockRepository.getMessagesException =
            Exception('Network error');

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Now fix the error and tap retry.
        mockRepository.getMessagesException = null;
        mockRepository.messagesToReturn = [
          _createMessage(content: 'After retry'),
        ];

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(find.text('After retry'), findsOneWidget);
        expect(find.text('Failed to load messages'), findsNothing);
      });
    });

    // ==========================================================
    // DATA STATE - MESSAGE DISPLAY
    // ==========================================================

    group('message display', () {
      testWidgets('should display messages as chat bubbles', (tester) async {
        mockRepository.messagesToReturn = [
          _createMessage(
            id: 'msg-1',
            senderId: 'current-user',
            content: 'Hi there!',
          ),
          _createMessage(
            id: 'msg-2',
            senderId: 'other-user',
            receiverId: 'current-user',
            content: 'Hello!',
          ),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(ChatBubbleWidget), findsNWidgets(2));
        expect(find.text('Hi there!'), findsOneWidget);
        expect(find.text('Hello!'), findsOneWidget);
      });

      testWidgets('should show listing title in header', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(
          buildPage(listingTitle: 'Beautiful Dress'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Beautiful Dress'), findsOneWidget);
      });

      testWidgets('should show Chat as default header title',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Chat'), findsOneWidget);
      });
    });

    // ==========================================================
    // SEND MESSAGE
    // ==========================================================

    group('send message', () {
      testWidgets('should send message when send button is tapped',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Type a message.
        await tester.enterText(find.byType(TextFormField), 'Test message');
        await tester.pump();

        // Tap send button.
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(mockRepository.sendMessageCallCount, 1);
        expect(mockRepository.sentMessage?.content, 'Test message');
      });

      testWidgets('should show sent message in the list', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'New message');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('New message'), findsOneWidget);
      });

      testWidgets('should clear input after sending', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        final textField = find.byType(TextFormField);
        await tester.enterText(textField, 'Clear me');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // The text field should be empty.
        final controller = tester
            .widget<TextFormField>(textField)
            .controller;
        expect(controller?.text, isEmpty);
      });
    });

    // ==========================================================
    // MARK AS READ
    // ==========================================================

    group('mark as read', () {
      testWidgets('should mark conversation as read on open',
          (tester) async {
        mockRepository.messagesToReturn = [
          _createMessage(
            senderId: 'other-user',
            receiverId: 'current-user',
            isRead: false,
          ),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(mockRepository.markAsReadCalled, isTrue);
        expect(
          mockRepository.lastMarkAsReadListingId,
          'listing-1',
        );
        expect(
          mockRepository.lastMarkAsReadOtherUserId,
          'other-user',
        );
      });
    });

    // ==========================================================
    // INPUT BAR
    // ==========================================================

    group('input bar', () {
      testWidgets('should have ChatInputBar', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(ChatInputBar), findsOneWidget);
        expect(find.text('Type a message...'), findsOneWidget);
      });
    });
  });
}

// =============================================================================
// DELAYED MOCK FOR LOADING STATE TESTING
// =============================================================================

class _DelayedMockRepository implements MarketplaceChatRepository {
  _DelayedMockRepository(this._completer);

  final Completer<List<MarketplaceMessage>> _completer;

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) => _completer.future;

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async =>
      throw UnimplementedError();

  @override
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) => const Stream.empty();

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {}

  @override
  Future<List<MarketplaceConversation>> getConversations() async => [];

  @override
  void unsubscribeAll() {}
}
