/// Tests for OfferBubbleWidget withdraw functionality.
///
/// Verifies that the withdraw button appears only for the buyer's
/// pending offers and that the callback is invoked correctly.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_message.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/offer_bubble_widget.dart';

void main() {
  final offerMessage = MarketplaceMessage(
    id: 'msg-1',
    listingId: 'listing-1',
    senderId: 'buyer-1',
    receiverId: 'seller-1',
    content: '{"amount_cents": 32000, "message": "Please consider"}',
    isRead: false,
    createdAt: DateTime(2026, 2, 6, 10, 0),
    messageType: 'offer',
    offerId: 'offer-1',
  );

  Widget buildWidget({
    bool isMe = true,
    String offerStatus = 'pending',
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    VoidCallback? onWithdraw,
    VoidCallback? onProceedToCheckout,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OfferBubbleWidget(
          message: offerMessage,
          isMe: isMe,
          offerStatus: offerStatus,
          onAccept: onAccept,
          onDecline: onDecline,
          onWithdraw: onWithdraw,
          onProceedToCheckout: onProceedToCheckout,
        ),
      ),
    );
  }

  group('OfferBubbleWidget withdraw', () {
    testWidgets('shows Withdraw button for buyer pending offer', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true, offerStatus: 'pending'));

      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('does NOT show Withdraw button for seller', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: false, offerStatus: 'pending'));

      expect(find.text('Withdraw'), findsNothing);
      // Seller sees Accept/Decline instead.
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('does NOT show Withdraw button for accepted offer',
        (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true, offerStatus: 'accepted'));

      expect(find.text('Withdraw'), findsNothing);
      // Buyer sees Proceed to Checkout instead.
      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('does NOT show Withdraw button for rejected offer',
        (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true, offerStatus: 'rejected'));

      expect(find.text('Withdraw'), findsNothing);
    });

    testWidgets('does NOT show Withdraw button for withdrawn offer',
        (tester) async {
      await tester
          .pumpWidget(buildWidget(isMe: true, offerStatus: 'withdrawn'));

      expect(find.text('Withdraw'), findsNothing);
    });

    testWidgets('invokes onWithdraw callback when tapped', (tester) async {
      bool called = false;
      await tester.pumpWidget(buildWidget(
        isMe: true,
        offerStatus: 'pending',
        onWithdraw: () => called = true,
      ));

      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });
  });
}
