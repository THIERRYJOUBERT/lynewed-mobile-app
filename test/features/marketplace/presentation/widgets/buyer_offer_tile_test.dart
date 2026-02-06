/// Tests for BuyerOfferTile widget.
///
/// Verifies display of buyer info, offer amount, status/action,
/// and offer count for conversation-style offer tiles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/buyer_offer_tile.dart';

// =============================================================================
// HELPERS
// =============================================================================

MarketplaceOffer _createOffer({
  String id = 'offer-1',
  String buyerId = 'buyer-1',
  String listingId = 'listing-1',
  int amountCents = 32000,
  String status = 'pending',
  DateTime? expiresAt,
}) {
  return MarketplaceOffer(
    id: id,
    listingId: listingId,
    buyerId: buyerId,
    amountCents: amountCents,
    status: status,
    expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 48)),
    createdAt: DateTime.now(),
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  Widget buildTile({
    String? buyerName,
    String? buyerAvatarUrl,
    MarketplaceOffer? latestOffer,
    int totalOfferCount = 1,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BuyerOfferTile(
          buyerName: buyerName,
          buyerAvatarUrl: buyerAvatarUrl,
          latestOffer: latestOffer ?? _createOffer(),
          totalOfferCount: totalOfferCount,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('BuyerOfferTile', () {
    testWidgets('should display buyer name', (tester) async {
      await tester.pumpWidget(buildTile(buyerName: 'Alice Smith'));
      expect(find.text('Alice Smith'), findsOneWidget);
    });

    testWidgets('should display fallback name when null', (tester) async {
      await tester.pumpWidget(buildTile(buyerName: null));
      expect(find.text('Buyer'), findsOneWidget);
    });

    testWidgets('should display buyer initial in avatar', (tester) async {
      await tester.pumpWidget(buildTile(buyerName: 'Alice'));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should display offer amount formatted as dollars',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(amountCents: 32000),
      ));
      expect(find.text('\$320.00'), findsOneWidget);
    });

    testWidgets('should show View Offer button for pending offers',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'pending'),
      ));
      expect(find.text('View Offer'), findsOneWidget);
    });

    testWidgets('should show ACCEPTED badge for accepted offers',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'accepted'),
      ));
      expect(find.text('ACCEPTED'), findsOneWidget);
    });

    testWidgets('should show REJECTED badge for rejected offers',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'rejected'),
      ));
      expect(find.text('REJECTED'), findsOneWidget);
    });

    testWidgets('should show EXPIRED badge for expired offers',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'expired'),
      ));
      expect(find.text('EXPIRED'), findsOneWidget);
    });

    testWidgets('should show WITHDRAWN badge for withdrawn offers',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'withdrawn'),
      ));
      expect(find.text('WITHDRAWN'), findsOneWidget);
    });

    testWidgets('should display offer count when multiple offers',
        (tester) async {
      await tester.pumpWidget(buildTile(totalOfferCount: 3));
      expect(find.text('3 offers'), findsOneWidget);
    });

    testWidgets('should not display offer count when only 1 offer',
        (tester) async {
      await tester.pumpWidget(buildTile(totalOfferCount: 1));
      expect(find.text('1 offer'), findsNothing);
      expect(find.text('1 offers'), findsNothing);
    });

    testWidgets('should call onTap when tile tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTile(onTap: () => tapped = true));

      await tester.tap(find.byType(BuyerOfferTile));
      expect(tapped, isTrue);
    });

    testWidgets('should call onTap when View Offer button tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(status: 'pending'),
        onTap: () => tapped = true,
      ));

      await tester.tap(find.text('View Offer'));
      expect(tapped, isTrue);
    });

    testWidgets('should treat expired pending offer as resolved',
        (tester) async {
      await tester.pumpWidget(buildTile(
        latestOffer: _createOffer(
          status: 'pending',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ));
      // Should NOT show View Offer for expired pending
      expect(find.text('View Offer'), findsNothing);
      expect(find.text('EXPIRED'), findsOneWidget);
    });
  });
}
