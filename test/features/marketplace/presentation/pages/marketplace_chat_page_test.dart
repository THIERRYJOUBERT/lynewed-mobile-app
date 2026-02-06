/// Tests for MarketplaceChatPage.
///
/// Verifies loading state, empty state, error state with retry,
/// message display, listing card, MessageComposer, and mark as read.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/marketplace_chat_page.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/chat_bubble_widget.dart';
import 'package:lynewed_beta/features/chat/presentation/widgets/message_composer.dart';

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
  int uploadAttachmentCallCount = 0;
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
    String messageType = 'text',
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMimeType,
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
      messageType: messageType,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      attachmentMimeType: attachmentMimeType,
    );
    return sentMessage!;
  }

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String listingId,
  }) async {
    uploadAttachmentCallCount++;
    return 'uploads/$listingId/$fileName';
  }

  @override
  Future<String?> getSignedUrl(String storagePath) async {
    return 'https://example.com/signed/$storagePath';
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
  Future<MarketplaceMessage> sendOfferMessage({
    required String listingId,
    required String receiverId,
    required String offerId,
    required int amountCents,
    String? message,
  }) async {
    return MarketplaceMessage(
      id: 'offer-msg-1',
      listingId: listingId,
      senderId: 'current-user',
      receiverId: receiverId,
      content: '{"amount_cents": $amountCents}',
      isRead: false,
      createdAt: DateTime.now(),
      messageType: 'offer',
      offerId: offerId,
    );
  }

  @override
  Future<MarketplaceMessage> sendSystemMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async {
    return MarketplaceMessage(
      id: 'system-msg-1',
      listingId: listingId,
      senderId: 'current-user',
      receiverId: receiverId,
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
      messageType: 'system',
    );
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

class FakeOfferRepository implements MarketplaceOfferRepository {
  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async => throw UnimplementedError();

  @override
  Future<void> acceptOffer(String offerId) async {}

  @override
  Future<void> rejectOffer(String offerId) async {}

  @override
  Future<void> withdrawOffer(String offerId) async {}

  @override
  Future<List<OfferDisplayModel>> getOffersForListing(String listingId) async =>
      [];

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
          String listingId) async =>
      null;

  @override
  Future<List<OfferDisplayModel>> getMyOffers() async => [];

  @override
  Future<MarketplaceOffer> getOfferById(String offerId) async =>
      throw UnimplementedError();
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
  String messageType = 'text',
}) {
  return MarketplaceMessage(
    id: id,
    listingId: listingId,
    senderId: senderId,
    receiverId: receiverId,
    content: content,
    isRead: isRead,
    createdAt: createdAt ?? _now,
    messageType: messageType,
  );
}

void main() {
  late MockMarketplaceChatRepository mockRepository;
  late FakeOfferRepository fakeOfferRepository;

  setUp(() {
    mockRepository = MockMarketplaceChatRepository();
    fakeOfferRepository = FakeOfferRepository();
  });

  tearDown(() {
    mockRepository.dispose();
  });

  Widget buildPage({
    String listingId = 'listing-1',
    String otherUserId = 'other-user',
    String? listingTitle,
    int? listingPriceCents,
    String? listingCoverUrl,
    String? otherUserName,
    String? otherUserAvatarUrl,
    String currentUserId = 'current-user',
  }) {
    return MaterialApp(
      home: MarketplaceChatPage(
        listingId: listingId,
        otherUserId: otherUserId,
        listingTitle: listingTitle,
        listingPriceCents: listingPriceCents,
        listingCoverUrl: listingCoverUrl,
        otherUserName: otherUserName,
        otherUserAvatarUrl: otherUserAvatarUrl,
        repository: mockRepository,
        offerRepository: fakeOfferRepository,
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
        final delayedRepo = _DelayedMockRepository(completer);

        await tester.pumpWidget(
          MaterialApp(
            home: MarketplaceChatPage(
              listingId: 'listing-1',
              otherUserId: 'other-user',
              repository: delayedRepo,
              offerRepository: fakeOfferRepository,
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
    });

    // ==========================================================
    // HEADER
    // ==========================================================

    group('header', () {
      testWidgets('should show Conversation as header title when no name',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.text('Conversation'), findsOneWidget);
      });

      testWidgets('should show seller name in header when provided',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(
          buildPage(otherUserName: 'Marie Dupont'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Marie Dupont'), findsOneWidget);
        expect(find.text('Conversation'), findsNothing);
      });
    });

    // ==========================================================
    // LISTING CARD
    // ==========================================================

    group('listing card', () {
      testWidgets('should show listing card with title and price',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(
          buildPage(
            listingTitle: 'Beautiful Dress',
            listingPriceCents: 35000,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Beautiful Dress'), findsOneWidget);
        expect(find.text('\$350.00'), findsOneWidget);
      });

      testWidgets('should show seller name in listing card',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(
          buildPage(
            listingTitle: 'Wedding Veil',
            otherUserName: 'Sophie Martin',
          ),
        );
        await tester.pumpAndSettle();

        // Seller name appears in both the header and the listing card
        expect(find.text('Sophie Martin'), findsNWidgets(2));
      });

      testWidgets('should hide listing card when no info provided',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // SizedBox.shrink is rendered when no listing info.
        // Verify no listing-specific text.
        expect(find.text('Listing'), findsNothing);
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

        // Type a message in the TextField.
        await tester.enterText(find.byType(TextField), 'Test message');
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

        await tester.enterText(find.byType(TextField), 'New message');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('New message'), findsOneWidget);
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
    // COMPOSER
    // ==========================================================

    group('composer', () {
      testWidgets('should have MessageComposer', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        expect(find.byType(MessageComposer), findsOneWidget);
        expect(find.text('Write a message...'), findsOneWidget);
      });
    });

    // ==========================================================
    // REAL-TIME MESSAGES
    // ==========================================================

    group('real-time messages', () {
      testWidgets('should display incoming real-time message',
          (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Simulate real-time message.
        mockRepository.emitRealtimeMessage(
          _createMessage(
            id: 'rt-1',
            senderId: 'other-user',
            receiverId: 'current-user',
            content: 'Live message!',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Live message!'), findsOneWidget);
      });
    });

    // ==========================================================
    // DISPOSE
    // ==========================================================

    group('dispose', () {
      testWidgets('should unsubscribe on dispose', (tester) async {
        mockRepository.messagesToReturn = [];

        await tester.pumpWidget(buildPage());
        await tester.pumpAndSettle();

        // Navigate away to trigger dispose.
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        expect(mockRepository.unsubscribeAllCalled, isTrue);
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
  }) => const Stream.empty();

  @override
  Future<void> markConversationAsRead({
    required String listingId,
    required String otherUserId,
  }) async {}

  @override
  Future<List<MarketplaceConversation>> getConversations() async => [];

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
