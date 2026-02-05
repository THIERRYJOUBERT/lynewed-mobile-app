/// Tests for OfferDisplayModel.
///
/// Verifies the display model wrapping MarketplaceOffer with buyer profile info.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/marketplace_offer.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/offer_display_model.dart';

void main() {
  final now = DateTime(2026, 2, 4, 10, 0);
  final expiresAt = now.add(const Duration(hours: 48));

  MarketplaceOffer createOffer({
    String id = 'offer-1',
    String listingId = 'listing-1',
    String buyerId = 'buyer-1',
    int amountCents = 20000,
    String? message,
    String status = 'pending',
  }) {
    return MarketplaceOffer(
      id: id,
      listingId: listingId,
      buyerId: buyerId,
      amountCents: amountCents,
      message: message,
      status: status,
      expiresAt: expiresAt,
      createdAt: now,
    );
  }

  group('OfferDisplayModel', () {
    test('should create with required fields', () {
      final offer = createOffer();
      final model = OfferDisplayModel(offer: offer);

      expect(model.offer, offer);
      expect(model.buyerName, isNull);
      expect(model.buyerAvatarUrl, isNull);
      expect(model.listingTitle, isNull);
      expect(model.listingPriceCents, isNull);
    });

    test('should create with all optional fields', () {
      final offer = createOffer();
      final model = OfferDisplayModel(
        offer: offer,
        buyerName: 'Jane Doe',
        buyerAvatarUrl: 'https://example.com/avatar.jpg',
        listingTitle: 'Beautiful Dress',
        listingPriceCents: 30000,
      );

      expect(model.offer, offer);
      expect(model.buyerName, 'Jane Doe');
      expect(model.buyerAvatarUrl, 'https://example.com/avatar.jpg');
      expect(model.listingTitle, 'Beautiful Dress');
      expect(model.listingPriceCents, 30000);
    });

    test('should expose offer properties through offer field', () {
      final offer = createOffer(
        amountCents: 15000,
        message: 'Please accept!',
        status: 'pending',
      );
      final model = OfferDisplayModel(offer: offer);

      expect(model.offer.amountInDollars, 150.0);
      expect(model.offer.isPending, isTrue);
      expect(model.offer.message, 'Please accept!');
    });

    test('should support equality based on offer', () {
      final offer = createOffer();
      final model1 = OfferDisplayModel(offer: offer, buyerName: 'Jane');
      final model2 = OfferDisplayModel(offer: offer, buyerName: 'Jane');

      expect(model1, equals(model2));
    });

    test('should have different equality for different offers', () {
      final offer1 = createOffer(id: 'offer-1');
      final offer2 = createOffer(id: 'offer-2');
      final model1 = OfferDisplayModel(offer: offer1);
      final model2 = OfferDisplayModel(offer: offer2);

      expect(model1, isNot(equals(model2)));
    });
  });
}
