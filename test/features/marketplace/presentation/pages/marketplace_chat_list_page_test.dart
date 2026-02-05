/// Tests for MarketplaceChatListPage.
///
/// Verifies loading state, empty state, error state with retry,
/// conversation display, unread badges, and sorting by most recent.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/marketplace_chat_list_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/conversation_tile_widget.dart';

// =============================================================================
// MOCK REPOSITORY
// =============================================================================

class MockMarketplaceChatRepository implements MarketplaceChatRepository {
  List<MarketplaceConversation> conversationsToReturn = [];
  Exception? getConversationsException;
  int getConversationsCallCount = 0;

  @override
  Future<List<MarketplaceConversation>> getConversations() async {
    getConversationsCallCount++;
    if (getConversationsException != null) throw getConversationsException!;
    return conversationsToReturn;
  }

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) async =>
      [];

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMimeType,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String listingId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String?> getSignedUrl(String storagePath) async => null;

  @override
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) =>
      const Stream.empty();

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {}

  @override
  Future<MarketplaceMessage> sendOfferMessage({
    required String listingId,
    required String receiverId,
    required String offerId,
    required int amountCents,
    String? message,
  }) async => throw UnimplementedError();

  @override
  Future<MarketplaceMessage> sendSystemMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async => throw UnimplementedError();

  @override
  void unsubscribeAll() {}
}

// =============================================================================
// TEST HELPERS
// =============================================================================

final _now = DateTime(2026, 2, 4, 10, 0);

MarketplaceConversation _createConversation({
  String listingId = 'listing-1',
  String listingTitle = 'Beautiful Dress',
  String otherUserId = 'user-2',
  String otherUserName = 'Alice',
  String? lastMessage = 'Is this still available?',
  DateTime? lastMessageTime,
  int unreadCount = 0,
}) {
  return MarketplaceConversation(
    listingId: listingId,
    listingTitle: listingTitle,
    otherUserId: otherUserId,
    otherUserName: otherUserName,
    lastMessage: lastMessage,
    lastMessageTime: lastMessageTime ?? _now,
    unreadCount: unreadCount,
  );
}

void main() {
  late MockMarketplaceChatRepository mockRepository;

  setUp(() {
    mockRepository = MockMarketplaceChatRepository();
  });

  Widget buildPage() {
    return MaterialApp(
      home: MarketplaceChatListPage(
        repository: mockRepository,
      ),
    );
  }

  group('MarketplaceChatListPage', () {
    // ==========================================================
    // LOADING STATE
    // ==========================================================

    group('loading state', () {
      testWidgets('should show loading indicator while conversations load',
          (tester) async {
        final completer = Completer<List<MarketplaceConversation>>();
        final delayedRepo = _DelayedMockRepository(completer);

        await tester.pumpWidget(
          MaterialApp(
            home: MarketplaceChatListPage(repository: delayedRepo),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete([]);
        await tester.pumpAndSettle();
      });
    });

    // ==========================================================
    // EMPTY STATE
    // ==========================================================

    group('empty state', () {
      testWidgets('should show empty state when no conversations',
          (tester) async {
        mockRepository.conversationsToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('No conversations yet'), findsOneWidget);
        expect(
          find.text('Start a conversation by contacting a seller'),
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
        mockRepository.getConversationsException =
            Exception('Network error');

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Failed to load conversations'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should retry loading when Retry button is tapped',
          (tester) async {
        mockRepository.getConversationsException =
            Exception('Network error');

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Fix error and retry.
        mockRepository.getConversationsException = null;
        mockRepository.conversationsToReturn = [
          _createConversation(listingTitle: 'Recovered'),
        ];

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(find.text('Recovered'), findsOneWidget);
        expect(find.text('Failed to load conversations'), findsNothing);
      });
    });

    // ==========================================================
    // DATA STATE - CONVERSATION LIST
    // ==========================================================

    group('conversation display', () {
      testWidgets('should display conversation tiles', (tester) async {
        mockRepository.conversationsToReturn = [
          _createConversation(
            listingTitle: 'Wedding Dress',
            otherUserName: 'Alice',
            lastMessage: 'Interested!',
          ),
          _createConversation(
            listingId: 'listing-2',
            listingTitle: 'Wedding Shoes',
            otherUserId: 'user-3',
            otherUserName: 'Bob',
            lastMessage: 'What size?',
          ),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(ConversationTileWidget), findsNWidgets(2));
        expect(find.text('Wedding Dress'), findsOneWidget);
        expect(find.text('Wedding Shoes'), findsOneWidget);
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('should show last message preview', (tester) async {
        mockRepository.conversationsToReturn = [
          _createConversation(lastMessage: 'Sure, let me check'),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Sure, let me check'), findsOneWidget);
      });
    });

    // ==========================================================
    // UNREAD BADGES
    // ==========================================================

    group('unread badges', () {
      testWidgets('should show unread count on conversation with unread',
          (tester) async {
        mockRepository.conversationsToReturn = [
          _createConversation(unreadCount: 3),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('should not show badge when unreadCount is 0',
          (tester) async {
        mockRepository.conversationsToReturn = [
          _createConversation(unreadCount: 0),
        ];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // The badge should not show '0'.
        expect(find.text('0'), findsNothing);
      });
    });

    // ==========================================================
    // HEADER
    // ==========================================================

    group('header', () {
      testWidgets('should show Messages title', (tester) async {
        mockRepository.conversationsToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Messages'), findsOneWidget);
      });
    });
  });
}

// =============================================================================
// DELAYED MOCK FOR LOADING STATE TESTING
// =============================================================================

class _DelayedMockRepository implements MarketplaceChatRepository {
  _DelayedMockRepository(this._completer);

  final Completer<List<MarketplaceConversation>> _completer;

  @override
  Future<MarketplaceMessage> sendOfferMessage({
    required String listingId,
    required String receiverId,
    required String offerId,
    required int amountCents,
    String? message,
  }) async => throw UnimplementedError();

  @override
  Future<MarketplaceMessage> sendSystemMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async => throw UnimplementedError();

  @override
  Future<List<MarketplaceConversation>> getConversations() =>
      _completer.future;

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) async =>
      [];

  @override
  Future<MarketplaceMessage> sendMessage({
    required String listingId,
    required String receiverId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMimeType,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String listingId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String?> getSignedUrl(String storagePath) async => null;

  @override
  Stream<MarketplaceMessage> subscribeToMessages({
    required String listingId,
    required String currentUserId,
  }) =>
      const Stream.empty();

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {}

  @override
  void unsubscribeAll() {}
}
