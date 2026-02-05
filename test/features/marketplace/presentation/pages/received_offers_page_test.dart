/// Tests for ReceivedOffersPage.
///
/// Verifies loading, empty, error, and data states.
/// Tests accept and reject offer actions.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/pages/received_offers_page.dart';

// =============================================================================
// FAKE REPOSITORIES
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  List<OfferDisplayModel> offersForListing = [];
  Exception? getOffersException;
  int acceptCallCount = 0;
  int rejectCallCount = 0;
  String? lastAcceptedId;
  String? lastRejectedId;

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> acceptOffer(String offerId) async {
    acceptCallCount++;
    lastAcceptedId = offerId;
  }

  @override
  Future<void> rejectOffer(String offerId) async {
    rejectCallCount++;
    lastRejectedId = offerId;
  }

  @override
  Future<void> withdrawOffer(String offerId) async {}

  @override
  Future<List<OfferDisplayModel>> getOffersForListing(
      String listingId) async {
    if (getOffersException != null) throw getOffersException!;
    return offersForListing;
  }

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

class FakeChatRepository implements MarketplaceChatRepository {
  int sendSystemMessageCount = 0;
  String? lastSystemMessageContent;

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
  }) async => throw UnimplementedError();

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String fileName,
    required String listingId,
  }) async => throw UnimplementedError();

  @override
  Future<String?> getSignedUrl(String storagePath) async => null;

  @override
  Future<List<MarketplaceMessage>> getMessages({
    required String listingId,
    required String otherUserId,
    int limit = 100,
  }) async => [];

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

  @override
  Future<MarketplaceMessage> sendOfferMessage({
    required String listingId,
    required String receiverId,
    required String offerId,
    required int amountCents,
    String? message,
  }) async => MarketplaceMessage(
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

  @override
  Future<MarketplaceMessage> sendSystemMessage({
    required String listingId,
    required String receiverId,
    required String content,
  }) async {
    sendSystemMessageCount++;
    lastSystemMessageContent = content;
    return MarketplaceMessage(
      id: 'system-msg-$sendSystemMessageCount',
      listingId: listingId,
      senderId: 'current-user',
      receiverId: receiverId,
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
      messageType: 'system',
    );
  }
}

// =============================================================================
// HELPERS
// =============================================================================

OfferDisplayModel _createOfferModel({
  String id = 'offer-1',
  String listingId = 'listing-1',
  String buyerId = 'buyer-1',
  int amountCents = 20000,
  String status = 'pending',
  String? buyerName,
}) {
  return OfferDisplayModel(
    offer: MarketplaceOffer(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      amountCents: amountCents,
      status: status,
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      createdAt: DateTime.now(),
    ),
    buyerName: buyerName,
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  late FakeOfferRepository fakeRepository;
  late FakeChatRepository fakeChatRepository;

  setUp(() {
    fakeRepository = FakeOfferRepository();
    fakeChatRepository = FakeChatRepository();
  });

  Widget buildPage({
    String listingId = 'listing-1',
    String listingTitle = 'Beautiful Dress',
  }) {
    return MaterialApp(
      home: ReceivedOffersPage(
        listingId: listingId,
        listingTitle: listingTitle,
        repository: fakeRepository,
        chatRepository: fakeChatRepository,
      ),
    );
  }

  group('ReceivedOffersPage', () {
    testWidgets('should show title in app bar', (tester) async {
      fakeRepository.offersForListing = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Offers Received'), findsOneWidget);
    });

    testWidgets('should show empty state when no offers', (tester) async {
      fakeRepository.offersForListing = [];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('No offers yet'), findsOneWidget);
    });

    testWidgets('should show error state on failure', (tester) async {
      fakeRepository.getOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load offers'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should retry after error', (tester) async {
      fakeRepository.getOffersException = Exception('Network error');

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Fix error and retry.
      fakeRepository.getOffersException = null;
      fakeRepository.offersForListing = [
        _createOfferModel(amountCents: 20000),
      ];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
    });

    testWidgets('should display offers list', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(id: 'offer-1', amountCents: 20000),
        _createOfferModel(
            id: 'offer-2', buyerId: 'buyer-2', amountCents: 25000),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('\$250.00'), findsOneWidget);
    });

    testWidgets('should accept offer when Accept tapped', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(id: 'offer-1', amountCents: 20000),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(fakeRepository.acceptCallCount, 1);
      expect(fakeRepository.lastAcceptedId, 'offer-1');
    });

    testWidgets('should send system message on accept', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(id: 'offer-1', amountCents: 20000),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(fakeChatRepository.sendSystemMessageCount, 1);
      expect(fakeChatRepository.lastSystemMessageContent, 'Offer accepted!');
    });

    testWidgets('should reject offer when Decline tapped', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(id: 'offer-1', amountCents: 20000),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      expect(fakeRepository.rejectCallCount, 1);
      expect(fakeRepository.lastRejectedId, 'offer-1');
    });

    testWidgets('should send system message on decline', (tester) async {
      fakeRepository.offersForListing = [
        _createOfferModel(id: 'offer-1', amountCents: 20000),
      ];

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      expect(fakeChatRepository.sendSystemMessageCount, 1);
      expect(fakeChatRepository.lastSystemMessageContent, 'Offer declined');
    });
  });
}
