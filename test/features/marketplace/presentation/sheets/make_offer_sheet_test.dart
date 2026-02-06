/// Tests for MakeOfferSheet.
///
/// Verifies sheet displays listing price, has amount/message inputs,
/// validates input, and calls repository on submit.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_conversation.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_chat_repository.dart';
import 'package:lynewed_beta/features/marketplace/domain/repositories/marketplace_offer_repository.dart';
import 'package:lynewed_beta/features/marketplace/presentation/sheets/make_offer_sheet.dart';

// =============================================================================
// FAKE REPOSITORY
// =============================================================================

class FakeOfferRepository implements MarketplaceOfferRepository {
  MarketplaceOffer? lastCreatedOffer;
  int createOfferCallCount = 0;
  Exception? createOfferException;
  MarketplaceOffer? pendingOffer;
  bool hasAcceptedOffer = false;

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async {
    createOfferCallCount++;
    if (createOfferException != null) throw createOfferException!;

    lastCreatedOffer = MarketplaceOffer(
      id: 'offer-$createOfferCallCount',
      listingId: listingId,
      buyerId: 'buyer-1',
      amountCents: amountCents,
      message: message,
      status: 'pending',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      createdAt: DateTime.now(),
    );
    return lastCreatedOffer!;
  }

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
      pendingOffer;

  @override
  Future<List<OfferDisplayModel>> getMyOffers() async => [];

  @override
  Future<List<OfferDisplayModel>> getOffersAwaitingMyPayment() async => [];

  @override
  Future<MarketplaceOffer> getOfferById(String offerId) async =>
      throw UnimplementedError();

  @override
  Future<bool> hasAcceptedOfferForListing(String listingId) async =>
      hasAcceptedOffer;

}
class FakeChatRepository implements MarketplaceChatRepository {
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
  }) async => MarketplaceMessage(
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

  Widget buildSheet({
    String listingId = 'listing-1',
    String listingTitle = 'Beautiful Dress',
    int listingPriceCents = 30000,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => MakeOfferSheet(
                  listingId: listingId,
                  listingTitle: listingTitle,
                  listingPriceCents: listingPriceCents,
                  receiverId: 'seller-1',
                  repository: fakeRepository,
                  chatRepository: fakeChatRepository,
                ),
              );
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester, {
    String listingId = 'listing-1',
    String listingTitle = 'Beautiful Dress',
    int listingPriceCents = 30000,
  }) async {
    await tester.pumpWidget(buildSheet(
      listingId: listingId,
      listingTitle: listingTitle,
      listingPriceCents: listingPriceCents,
    ));
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();
  }

  group('MakeOfferSheet', () {
    testWidgets('should display sheet title', (tester) async {
      await openSheet(tester);

      expect(find.text('Make an Offer'), findsOneWidget);
    });

    testWidgets('should display listed price', (tester) async {
      await openSheet(tester, listingPriceCents: 30000);

      expect(find.textContaining('300.00'), findsOneWidget);
    });

    testWidgets('should have amount input field', (tester) async {
      await openSheet(tester);

      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('should have expiration notice', (tester) async {
      await openSheet(tester);

      expect(
        find.text('This offer will expire in 48 hours'),
        findsOneWidget,
      );
    });

    testWidgets('should have send offer button', (tester) async {
      await openSheet(tester);

      expect(find.text('Send Offer'), findsOneWidget);
    });

    testWidgets('should call repository on valid submit', (tester) async {
      await openSheet(tester);

      // Enter a valid amount.
      final amountFields = find.byType(TextFormField);
      await tester.enterText(amountFields.first, '250');
      await tester.pump();

      // Scroll to and tap Send Offer (inside scrollable content).
      await tester.ensureVisible(find.text('Send Offer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Offer'));
      await tester.pumpAndSettle();

      expect(fakeRepository.createOfferCallCount, 1);
      expect(fakeRepository.lastCreatedOffer?.amountCents, 25000);
    });

    testWidgets('should show error for duplicate pending offer',
        (tester) async {
      fakeRepository.pendingOffer = MarketplaceOffer(
        id: 'existing-offer',
        listingId: 'listing-1',
        buyerId: 'buyer-1',
        amountCents: 20000,
        status: 'pending',
        expiresAt: DateTime.now().add(const Duration(hours: 48)),
        createdAt: DateTime.now(),
      );

      await openSheet(tester);

      // Enter a valid amount.
      final amountFields = find.byType(TextFormField);
      await tester.enterText(amountFields.first, '300');
      await tester.pump();

      // Scroll to and tap Send Offer.
      await tester.ensureVisible(find.text('Send Offer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Offer'));
      await tester.pumpAndSettle();

      // Should show error, not create offer.
      expect(fakeRepository.createOfferCallCount, 0);
      expect(find.textContaining('already have a pending offer'),
          findsOneWidget);
    });

    testWidgets('should have numeric input formatter on amount field',
        (tester) async {
      await openSheet(tester);

      // The underlying TextField (inside TextFormField) exposes inputFormatters.
      final textFields = find.byType(TextField);
      final amountTextField =
          tester.widget<TextField>(textFields.first);
      expect(amountTextField.inputFormatters, isNotNull);
      expect(
        amountTextField.inputFormatters!
            .any((f) => f is FilteringTextInputFormatter),
        isTrue,
      );
    });

    testWidgets('should handle comma as decimal separator', (tester) async {
      await openSheet(tester);

      final amountFields = find.byType(TextFormField);
      await tester.enterText(amountFields.first, '250,50');
      await tester.pump();

      // Scroll to and tap Send Offer - should normalize comma to period.
      await tester.ensureVisible(find.text('Send Offer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Offer'));
      await tester.pumpAndSettle();

      expect(fakeRepository.createOfferCallCount, 1);
      expect(fakeRepository.lastCreatedOffer?.amountCents, 25050);
    });

    testWidgets('should show error when createOffer throws', (tester) async {
      fakeRepository.createOfferException =
          Exception('Network error');

      await openSheet(tester);

      final amountFields = find.byType(TextFormField);
      await tester.enterText(amountFields.first, '250');
      await tester.pump();

      await tester.ensureVisible(find.text('Send Offer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send Offer'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Network error'), findsOneWidget);
    });
  });
}
