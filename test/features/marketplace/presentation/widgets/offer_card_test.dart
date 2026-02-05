/// Tests for OfferCard widget.
///
/// Verifies offer display, status badges, action buttons for
/// pending/accepted/rejected/expired offers, and callback behavior.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/offer_card.dart';

// =============================================================================
// TEST HELPERS
// =============================================================================

final _now = DateTime(2026, 2, 4, 10, 0);
final _expiresAt = _now.add(const Duration(hours: 48));

OfferDisplayModel _createModel({
  String id = 'offer-1',
  String status = 'pending',
  int amountCents = 20000,
  String? message,
  String buyerName = 'Jane Doe',
  String? listingTitle,
  DateTime? expiresAt,
}) {
  return OfferDisplayModel(
    offer: MarketplaceOffer(
      id: id,
      listingId: 'listing-1',
      buyerId: 'buyer-1',
      amountCents: amountCents,
      message: message,
      status: status,
      expiresAt: expiresAt ?? _expiresAt,
      createdAt: _now,
    ),
    buyerName: buyerName,
    listingTitle: listingTitle,
  );
}

void main() {
  group('OfferCard', () {
    // ===================================================================
    // DISPLAY
    // ===================================================================

    group('display', () {
      testWidgets('should display offer amount', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(amountCents: 25000),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('\$250.00'), findsOneWidget);
      });

      testWidgets('should display buyer name', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(buyerName: 'Alice'),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('should display message when present', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(message: 'Beautiful dress!'),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('Beautiful dress!'), findsOneWidget);
      });

      testWidgets('should display listing title in buyer mode',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(listingTitle: 'Wedding Dress'),
                viewMode: OfferCardViewMode.buyer,
              ),
            ),
          ),
        );

        expect(find.text('Wedding Dress'), findsOneWidget);
      });
    });

    // ===================================================================
    // SELLER VIEW - ACTIONS
    // ===================================================================

    group('seller view', () {
      testWidgets('should show Accept and Decline buttons for pending',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'pending'),
                viewMode: OfferCardViewMode.seller,
                onAccept: () {},
                onReject: () {},
              ),
            ),
          ),
        );

        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
      });

      testWidgets('should call onAccept when Accept tapped',
          (tester) async {
        var acceptCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'pending'),
                viewMode: OfferCardViewMode.seller,
                onAccept: () => acceptCalled = true,
                onReject: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.text('Accept'));
        expect(acceptCalled, isTrue);
      });

      testWidgets('should call onReject when Decline tapped',
          (tester) async {
        var rejectCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'pending'),
                viewMode: OfferCardViewMode.seller,
                onAccept: () {},
                onReject: () => rejectCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Decline'));
        expect(rejectCalled, isTrue);
      });

      testWidgets('should show accepted status badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'accepted'),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('ACCEPTED'), findsOneWidget);
        expect(find.text('Accept'), findsNothing);
      });

      testWidgets('should show rejected status badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'rejected'),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('REJECTED'), findsOneWidget);
      });

      testWidgets('should show expired status badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'expired'),
                viewMode: OfferCardViewMode.seller,
              ),
            ),
          ),
        );

        expect(find.text('EXPIRED'), findsOneWidget);
      });
    });

    // ===================================================================
    // BUYER VIEW - ACTIONS
    // ===================================================================

    group('buyer view', () {
      testWidgets('should show Withdraw button for pending', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'pending'),
                viewMode: OfferCardViewMode.buyer,
                onWithdraw: () {},
              ),
            ),
          ),
        );

        expect(find.text('Withdraw'), findsOneWidget);
      });

      testWidgets('should call onWithdraw when tapped', (tester) async {
        var withdrawCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'pending'),
                viewMode: OfferCardViewMode.buyer,
                onWithdraw: () => withdrawCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Withdraw'));
        expect(withdrawCalled, isTrue);
      });

      testWidgets('should show withdrawn status badge', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfferCard(
                model: _createModel(status: 'withdrawn'),
                viewMode: OfferCardViewMode.buyer,
              ),
            ),
          ),
        );

        expect(find.text('WITHDRAWN'), findsOneWidget);
        expect(find.text('Withdraw'), findsNothing);
      });
    });
  });
}
